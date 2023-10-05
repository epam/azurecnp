FROM mcr.microsoft.com/dotnet/aspnet:6.0
WORKDIR /app
COPY app/ .
EXPOSE 5000
RUN groupadd -g 1500 app  \
    && useradd -u 1500 -g 1500 app \
    && chown app:app -R /app
USER app:app
CMD [ "dotnet", "#{APP_PROJECT_NAME}#.dll" ]