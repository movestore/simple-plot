FROM registry.gitlab.com/couchbits/movestore/movestore-groundcontrol/movestore-apps/copilot-shiny:v0002-pilot1.0.0-r3.6.3-s1.4.0.2

# install system dependencies required by this app
RUN apt-get update && apt-get install -qq -y --no-install-recommends libgdal-dev
RUN apt-get update && apt-get install -qq -y --no-install-recommends libudunits2-dev
RUN apt-get update && apt-get install -qq -y --no-install-recommends libfontconfig1-dev
RUN apt-get update && apt-get install -qq -y --no-install-recommends libcairo2-dev

WORKDIR /root/app

# install the R dependencies this app needs
RUN Rscript -e 'remotes::install_version("leaflet")'
RUN Rscript -e 'remotes::install_version("leaflet.extras")'
RUN Rscript -e 'remotes::install_version("move")'
RUN Rscript -e 'remotes::install_version("sp")'
RUN Rscript -e 'remotes::install_version("pals")'
RUN Rscript -e 'remotes::install_version("mapview")'
RUN Rscript -e 'packrat::snapshot()'

# copy the app as last as possible
# therefore following builds can use the docker cache of the R dependency installations
COPY ShinyModule.R .

# start again from the vanilla r-base image and copy only
# the needed binaries from the buildstage.
# this will reduce the resulting image size dramatically
# FROM rocker/r-base:3.6.3
# WORKDIR /root/app
# COPY --from=buildstage /root/app .

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/root/app/app.jar"]