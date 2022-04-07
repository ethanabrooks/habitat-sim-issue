FROM docker.io/continuumio/miniconda3:4.9.2 AS build

# Install the package as normal:
RUN conda create -n habitat

# Install conda-pack (per https://pythonspeed.com/articles/conda-docker-image-size/)
# and habitat-sim
RUN conda install \
  conda-pack \
  habitat-sim==0.2.1 \
  # for running habitat-sim headless:
  headless==1.0=0 \
  -c pytorch -c conda-forge -c aihabitat

# Use conda-pack to create a standalone enviornment
# in /venv:
RUN conda-pack -n habitat -o /tmp/env.tar && \
  mkdir /venv && cd /venv && tar xf /tmp/env.tar && \
  rm /tmp/env.tar

# We've put venv in same path it'll be in final image,
# so now fix up paths:
RUN /venv/bin/conda-unpack

# The runtime-stage image; we can use Debian as the
# base image since the Conda env also includes Python
# for us.
FROM nvidia/cudagl:11.4.0-devel-ubuntu20.04 as base

# Copy /venv from the previous stage:
COPY --from=build /venv /venv
COPY --from=build /opt/conda/ /opt/conda/

RUN apt-get update -q \
 && DEBIAN_FRONTEND="noninteractive" \
    apt-get install -yq \
      git \
      redis \

      # cv2
      ffmpeg \
      libsm6 \
      libxext6 \
 && apt-get clean

# add /venv to Path for access to python and pip
ENV PATH="/venv/bin:/opt/conda/bin/:$PATH"
ENV PYTHONBREAKPOINT=ipdb.set_trace

COPY pyproject.toml poetry.lock .
RUN pip install poetry==1.1.12 \
    # https://github.com/python-poetry/poetry/discussions/1879#discussioncomment-216870
    && poetry export --dev --without-hashes -f requirements.txt | pip install -r /dev/stdin 

WORKDIR "/project"

COPY . .

ENTRYPOINT ["python"]
