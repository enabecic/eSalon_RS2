FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 5224
ENV ASPNETCORE_URLS=http://+:5224

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY . .

FROM build AS publish
RUN dotnet publish "eSalon.API/eSalon.API.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .

ENTRYPOINT ["dotnet", "eSalon.API.dll"]