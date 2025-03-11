# Cyclistic Bike Share
This repository contains the source code used to produce my Capstone Project for the [Google Data Analytics Professional Certificate](https://grow.google/certificates/en_uk/certificates/data-analytics/?utm_source=google&utm_medium=paidsearch&utm_campaign=ha-sem-bk-data-exa__geo—UK&utm_term=google%20data%20analytics%20professional%20certificate&gclsrc=aw.ds&gad_source=1&gbraid=0AAAAA9UI9ejmZlJzsSNlAUxzqdvaWch7r&gclid=CjwKCAiAp4O8BhAkEiwAqv2UqE9zR11P0MSDuN9xc5ezDuRVvEndRc5_Vk9cqKekoJm8kCxAuPKF0BoCvmMQAvD_BwE).

## Description
The fictional bike-share company Cyclistic wishes to maximize the number of annual memberships by converting casual riders into annual members. The marketing team wishes to understand how casual riders and annual members use Cyclistic differently.

## Getting started
### Analysis
- [Blog post](https://www.datatranslator.co.uk/portfolio/cyclistic-bike-share/)
- [Case study on Tableau](https://public.tableau.com/app/profile/datatranslator/viz/CyclisticBikeShare_17374793232980/CaseStudy)

### Data
This project uses [trip data](https://divvy-tripdata.s3.amazonaws.com/index.html) for the year 2024 sourced from Divvy Bikes (under [licence](https://divvybikes.com/data-license-agreement) from [Lyft Bikes and Scooters, LLC](https://divvybikes-marketing-staging.lyft.net/system-data)).

To recreate this analysis, the following source data files should be downloaded and placed into the `/data/src` folder:

- [202401-divvy-tripdata.zip](https://divvy-tripdata.s3.amazonaws.com/202401-divvy-tripdata.zip)
- [202402-divvy-tripdata.zip](https://divvy-tripdata.s3.amazonaws.com/202402-divvy-tripdata.zip)
- [202403-divvy-tripdata.zip](https://divvy-tripdata.s3.amazonaws.com/202403-divvy-tripdata.zip)
- [202404-divvy-tripdata.zip](https://divvy-tripdata.s3.amazonaws.com/202404-divvy-tripdata.zip)
- [202405-divvy-tripdata.zip](https://divvy-tripdata.s3.amazonaws.com/202405-divvy-tripdata.zip)
- [202406-divvy-tripdata.zip](https://divvy-tripdata.s3.amazonaws.com/202406-divvy-tripdata.zip)
- [202407-divvy-tripdata.zip](https://divvy-tripdata.s3.amazonaws.com/202407-divvy-tripdata.zip)
- [202408-divvy-tripdata.zip](https://divvy-tripdata.s3.amazonaws.com/202408-divvy-tripdata.zip)
- [202409-divvy-tripdata.zip](https://divvy-tripdata.s3.amazonaws.com/202409-divvy-tripdata.zip)
- [202410-divvy-tripdata.zip](https://divvy-tripdata.s3.amazonaws.com/202410-divvy-tripdata.zip)
- [202411-divvy-tripdata.zip](https://divvy-tripdata.s3.amazonaws.com/202411-divvy-tripdata.zip)
- [202412-divvy-tripdata.zip](https://divvy-tripdata.s3.amazonaws.com/202412-divvy-tripdata.zip)

### Packages
This project uses `renv` for package management. To set up the packages needed for this project run the following code in the console:

```r
install.packages("renv")
renv::init()
```

## Author

- [Clare Gibson](https://www.surreydatagirl.com) - [surreydatagirl@gmail.com](mailto:surreydatagirl.com)

## Licence
This project is licensed under the CC0 1.0 Universal licence. See the [LICENSE](./LICENSE) file for details.

## Acknowledgements

- [Capstone project description](https://www.coursera.org/learn/google-data-analytics-capstone?specialization=google-data-analytics)
- Case study inspired by [this work](https://public.tableau.com/app/profile/joe.petosa/viz/CyclisticBikeshareinChicago/CyclisticBikeshareinChicago) by [Joey Petosa](https://www.joeypetosa.com)
