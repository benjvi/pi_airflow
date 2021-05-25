ARG PYTHON_MAJ_VER="3"
ARG PYTHON_MIN_VER="7"

ARG PYTHON_VER="${PYTHON_MAJ_VER}.${PYTHON_MIN_VER}"


FROM python:"${PYTHON_VER}"-slim-buster

RUN apt-get update -yqq \
    	&& apt-get upgrade -yqq \
    	&& apt-get install -yqq --no-install-recommends \
	apt-utils \
	build-essential \
	libffi-dev \
	libpq-dev \
	libssl-dev \
	vim

ARG PYTHON_VER
ARG AIRFLOW_EXTRAS="postgres,ssh"
ARG AIRFLOW_VERSION="1.10.12"
ARG CONSTRAINTS_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VER}.txt"
ARG PYTHON_DEPS=""
ARG UID=5000
ARG GID=5000

RUN groupadd -g "${GID}" -r airflow && \
    useradd -r -m -u "${UID}" -g airflow airflow

USER airflow

RUN pip install --user "apache-airflow[${AIRFLOW_EXTRAS}]==${AIRFLOW_VERSION}" \
    --constraint "${CONSTRAINTS_URL}" && \
    if [ -n "${PYTHON_DEPS}" ]; then pip install --user ${PYTHON_DEPS} \
    --constraint "${CONSTRAINTS_URL}"; fi

COPY ./entrypoint.sh /entrypoint.sh

EXPOSE 8080

ARG AIRFLOW_HOME="/app/airflow"

ENV AIRFLOW_HOME=${AIRFLOW_HOME}
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False
ENV AIRFLOW__WEBSERVER__EXPOSE_CONFIG=True
ENV PATH="/home/airflow/.local/bin:${PATH}"

USER root
RUN mkdir -p "/app/airflow" && chmod 777 /app/airflow

USER airflow

ENTRYPOINT [ "/entrypoint.sh" ]
