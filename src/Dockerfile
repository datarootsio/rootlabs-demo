# Dockerfile - this is a comment. Delete me if you want.
FROM python:3-alpine

RUN mkdir /app

COPY ["*.py", "requirements.txt", "app/"]
COPY ./templates app/templates/
WORKDIR /app

RUN pip install -r requirements.txt

EXPOSE 8000
CMD ["gunicorn", "wsgi:app"]
