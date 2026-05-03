FROM python:3.12-slim

WORKDIR /app

COPY projects/demo-api/ /app/projects/demo-api/
COPY artifacts/ /app/artifacts/

RUN pip install --no-cache-dir \
    fastapi>=0.115 \
    "uvicorn[standard]>=0.30" \
    pandas>=2.2 \
    pydantic>=2.8 \
    scalar-fastapi>=1.0.3

ENV PYTHONPATH=/app/projects/demo-api/src

EXPOSE 8000

CMD ["uvicorn", "student_behavior_demo_api.main:app", "--host", "0.0.0.0", "--port", "8000"]
