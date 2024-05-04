import { SQSEvent, Context } from "aws-lambda";
import { S3 } from "aws-sdk";
import sharp from "sharp";

const s3 = new S3();

export const handler = async (
  event: SQSEvent,
  _: Context,
): Promise<boolean> => {
  for (const record of event.Records) {
    const body = JSON.parse(record.body);
    const bucket = body.Records[0].s3.bucket.name;
    const key = decodeURIComponent(
      body.Records[0].s3.object.key.replace(/\+/g, " "),
    );

    try {
      console.log(`Downloading file from bucket "${bucket}" with key "${key}"`);

      // 画像取得
      const data = await s3
        .getObject({
          Bucket: bucket,
          Key: key,
        })
        .promise();

      const sourceImage = Buffer.from(data.Body as Buffer);
      console.log(`Downloaded file from bucket "${bucket}" with key "${key}"`);

      const contentType = data.ContentType || "";

      if (!contentType || !contentType.startsWith("image/")) {
        console.log("Object is not an image. Skipping.");
        continue;
      }

      const resizedImage = await sharp(sourceImage)
        .resize(300, 300) // リサイズしたい幅と高さを指定
        .toBuffer();

      const resizeBucket = `${process.env.RESIZE_BUCKET}`;

      console.log(
        `Uploading file from bucket "${resizeBucket}" with key "${key}"`,
      );

      // 画像アップロード
      await s3
        .putObject({
          Bucket: resizeBucket,
          Key: key,
          Body: resizedImage,
          ContentType: contentType,
        })
        .promise();

      console.log(
        `Uploaded file from bucket "${resizeBucket}" with key "${key}"`,
      );
    } catch (error) {
      console.error("Error processing image:", error);
      return false;
    }
  }
  return true;
};
