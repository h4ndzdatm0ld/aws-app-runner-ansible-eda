##############
# Dependencies
FROM python:3.9 as base

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y libssh-dev python3-apt

RUN pip install -U pip  && \
    curl -sSL https://install.python-poetry.org  | python3 -

ENV PATH="/root/.local/bin:$PATH"

RUN poetry config virtualenvs.create false

COPY pyproject.toml poetry.lock ./

RUN poetry install --no-root --only main

FROM base AS test

COPY . .

RUN poetry install --no-interaction --no-ansi --no-root

# Simple tests
RUN echo 'Running Flakeheaven' && \
    flakeheaven lint && \
    echo 'Running Black' && \
    black --check --diff . && \
    # echo 'Running Pylint' && \
    # find . -name '*.py' | xargs pylint && \
    echo 'Running Yamllint' && \
    yamllint . && \
    echo 'Running pydocstyle' && \
    pydocstyle . && \
    echo 'Running Bandit' && \
    bandit --recursive ./ --configfile .bandit.yml

FROM base AS ansible

WORKDIR /usr/src/app

ENV ANSIBLE_COLLECTIONS_PATH /usr/share/ansible/collections
ENV ANSIBLE_ROLES_PATH /usr/share/ansible/roles

COPY ./collections/requirements.yml ./collections/requirements.yml

# Just in case
RUN if [ -e collections/requirements.yml ]; then \
    ansible-galaxy collection install -r collections/requirements.yml; \
    fi

RUN if [ -e roles/requirements.yml ]; then \
    ansible-galaxy install -r roles/requirements.yml; \
    fi

#############
# Final image
#
# This creates a runnable CLI container
FROM python:3.9-slim AS cli

WORKDIR /usr/src/app

COPY --from=base /usr/src/app /usr/src/app
COPY --from=base /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=base /usr/local/bin /usr/local/bin
COPY --from=ansible /usr/share /usr/share
COPY --from=openjdk:20-slim /usr/local/openjdk-20 /usr/local/openjdk-20

COPY . .

ENV JAVA_HOME /usr/local/openjdk-20

EXPOSE 5000/tcp
EXPOSE 5000/udp

ENTRYPOINT ["ansible-rulebook"]