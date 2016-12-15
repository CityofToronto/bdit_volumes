# Traffic Volumes Modelling Project

## 1. Purpose
Develop a methodology for estimating traffic volumes on road segments in the City of Toronto.

## 2. Introduction
The core mission of the City of Toronto's Big Data Innovation Team is to leverage emerging data sources and analytical techniques to advance the City's understanding of its transportation networks. This work involves, among other objectives, the production of indicative corridor-specific and city-wide performance metrics. These metrics are reliant on disaggregate data with spatial and temporal coverage that generally encompass two measures:

- **Speed or Travel Times:** used as an indication of the road segment's performance; and

- **Traffic Volumes:** used as weights that feed into aggregate metrics.

The Team has access to third party GPS probe data that provides speed data across the City of Toronto in 1- or 5-minute bins. The availability of volume data, however, is limited to sparse counts across the network. The sparsity of these counts result in two inherent issues:

- **Spatial Relativity:** An inability to compare traffic volumes amongst segments as counts are taken over different time periods.

- **Variability:** An inability to capture the effects of seasonality, long-term trends, and day-to-day variability.

The City of Toronto's traffic volume collection efforts can be broken into three (3) buckets:

1. **Permanent Traffic Counts:** Loop detectors, most of which are under the jurisdiction of the RESCU traffic management system and primarily cover the Gardiner Expressway, Don Valley Parkway, Lakeshore Boulevard and Allen Road.

2. **Short Period Traffic Counts (SPTCs):** Volumes collected using temporary automatic traffic recorders (ATRs), and typically carried out over 3 or 7-day periods. These are typically gathered to support specific studies by Transportation Services (e.g. signal retiming studies) or other divisions as well as through a City-run rotating count program.

3. **Turning Movement Counts (TMCs):** Volumes can be inferred using manual turning movement counts, although these typically do not cover a full 24-hour period and may have significant gaps given the manual nature of these counts.

The purpose of this project is to leverage existing count data to develop a model that can produce volume estimates at specific locations at specific times, and is sensitive to time-of-day, day-of-week and seasonality effects, as well as long-term trends. These estimates will facilitate the development of volume-weighted congestion performance metrics, as well as allow the Team to produce detailed volume profiles that can feed into congestion reporting tools and AADT summaries.

## 3. Scope

- 

## 4. Project Tasks
**1. Map Source Geometries to Toronto Centreline:** Link Artery Codes used in the City's FLOW database to the City's Centreline shapefile, with additional descriptive fields (e.g. directionality) as necessary.

**2. Definition of Corridors:** Develop reproducible process for aggregating relevant centreline segments into corridors

**3. Literature Review:** Explore methods employed in other jurisdictions for interpolating or extrapolating traffic volumes both spatially and temporally, with a specific focus on cases where sparse counts exist. Produce summary of methods that may have value for this project for further exploration.

**4. Exploration of Methods:** Implement and compare methods deemed potentially feasible in *C.* to interpolating volumes on a subset of selected corridors.

**5. Data Harmonization (if necessary):**

**6. Model Development:**

**7. Model Validation:**

**8. Tool Deployment:**

## 5. Related Tasks
1. Explore the availability and value of alternative sources of volume data.
2. Develop process for identifying priority segments as candidates for the implementation of permanent and/or short period traffic count stations.
