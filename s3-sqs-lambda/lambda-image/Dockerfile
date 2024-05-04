FROM public.ecr.aws/lambda/nodejs:20 as builder
WORKDIR /usr/app
COPY src ./
COPY package.json ./
RUN npm install
RUN npm run build

FROM public.ecr.aws/lambda/nodejs:20
WORKDIR ${LAMBDA_TASK_ROOT}
RUN dnf update -y && \
  dnf install -y gcc-c++ findutils && \
  dnf clean all
COPY --from=builder /usr/app/dist/* ./
RUN npm install --arch=x64 --platform=linux --libc=glibc sharp
CMD ["index.handler"]