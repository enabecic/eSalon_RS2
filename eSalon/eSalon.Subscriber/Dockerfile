FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /app

COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet build "eSalon.Subscriber.csproj" -c Release -o /app/build

FROM mcr.microsoft.com/dotnet/runtime:7.0 AS runtime
WORKDIR /app
COPY --from=build /app/build .

ENTRYPOINT ["dotnet", "eSalon.Subscriber.dll"]
