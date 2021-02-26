FROM alpine
ADD app/ /app/
RUN apk add python3 py3-pip
WORKDIR /app
RUN pip install -r requirements.txt
CMD python3 app.py