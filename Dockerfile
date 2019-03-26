FROM postgres:11.2

RUN useradd -ms /bin/bash stolon

EXPOSE 5432

ADD ./stolon-keeper ./stolon-sentinel ./stolon-proxy ./stolonctl /usr/local/bin/

RUN chmod +x /usr/local/bin/stolon-keeper /usr/local/bin/stolon-sentinel /usr/local/bin/stolon-proxy /usr/local/bin/stolonctl