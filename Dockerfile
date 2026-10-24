
FROM python:3.11-slim
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
WORKDIR /app
COPY app/app.py .
RUN chown -R appuser:appgroup /app

# Switch to the non-root user
USER appuser
EXPOSE 8080

CMD ["python", "app.py"]
