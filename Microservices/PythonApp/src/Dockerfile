FROM python:3.8-alpine

ENV ENVIRONMENT="development"
ENV IMAGE_VERSION="v1"
ENV MESSAGE="default"

RUN mkdir /app

#Create a new user named 'appuser' and set it as the current user.
RUN adduser -D appuser
USER appuser

ADD ./app /app

WORKDIR /app

CMD ["python3", "app.py"]
