FROM swipl:latest

WORKDIR /app

COPY . /app

EXPOSE 4000

CMD ["swipl", "escape_room_web.pl", "--quiet"]
