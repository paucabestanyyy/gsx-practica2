FROM python:3.9-alpine
RUN adduser -D -u 1000 appuser
WORKDIR /app
COPY app.py .
RUN chown -R appuser:appuser /app
USER appuser
EXPOSE 8080
CMD ["python", "app.py"]
