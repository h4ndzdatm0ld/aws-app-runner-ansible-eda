##############
# Dependencies
FROM python:3.9 as base

ARG DOCKER_DEFAULT_PLATFORM=linux/amd64

WORKDIR /usr/src/app

# Install poetry for dep management
RUN pip install -U pip  && \
    curl -sSL https://install.python-poetry.org  | python3 -

ENV PATH="/root/.local/bin:$PATH"

RUN poetry config virtualenvs.create false

# Install project manifest
COPY pyproject.toml poetry.lock ./

# Install production dependencies
RUN poetry install --no-root --no-dev

FROM base AS test

# Copy in the application code
COPY . .

# --no-root declares not to install the project package since we're wanting to take advantage of caching dependency installation
# and the project is copied in and installed after this step
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

#############
# Ansible Collections
#
# This installs the Ansible Collections from collections/requirements.yml
# and the roles from roles/requirements.yml, as well as installing git.
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
FROM python:3.9 AS cli

WORKDIR /usr/src/app

COPY --from=base /usr/src/app /usr/src/app
COPY --from=base /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=base /usr/local/bin /usr/local/bin
COPY --from=ansible /usr/share /usr/share
COPY --from=openjdk:8-jre-slim /usr/local/openjdk-8 /usr/local/openjdk-8

COPY . .
RUN pip install aiohttp

ENV JAVA_HOME /usr/local/openjdk-8
RUN export JAVA_HOME

RUN ansible-playbook -i localhost, -c local ansible.eda.install_rulebook_cli

ENTRYPOINT ["ansible-rulebook"]