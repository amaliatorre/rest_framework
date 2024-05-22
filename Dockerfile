# Usa una imagen base de Python
FROM python:3.9-alpine3.13
# Mantenedor de la imagen
LABEL maintainer="londonappdeveloper.com"
# Configura Python para que no almacene el buffer de salida
ENV PYTHONUNBUFFERED 1
# Copia el archivo de requisitos a un directorio temporal
COPY ./requirements.txt /tmp/requirements.txt
# Copia el código de la aplicación
COPY ./app /app
# Establece el directorio de trabajo
WORKDIR /app
# Expone el puerto 8000 para la aplicación
EXPOSE 8000
# Instala las dependencias en un entorno virtual
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user
# Añade el entorno virtual al PATH
ENV PATH="/py/bin:$PATH"
# Establece el usuario no root para la ejecución del contenedor
USER django-user
