# Project no.17: Vessel wall to lumen ratio determination in adaptive optics retinal images

## Team
- Adriána Špaková
- Klára Sakmárová
- Vasilii Fedorov

## Goal
Design and realize automatic algorithm for vessel wall segmentation.<br> Determine the
vessel wall to lumen ratio. Test the proposed algorithm and evaluate the obtained
results.

![wwwsdsds](https://user-images.githubusercontent.com/62359460/187036136-71a84cde-fb85-423f-b648-881e24ef16ce.png)



## Related papers
[Lumen segmentation in magnetic resonance images](https://www.sciencedirect.com/science/article/pii/S0010482516302827)

[Morphometric analysis of small arteries in the humanretina using adaptive optics imaging](https://www.researchgate.net/publication/259651521_Morphometric_analysis_of_small_arteries_in_the_human_retina_using_adaptive_optics_imaging_Relationship_with_blood_pressure_and_focal_vascular_changes)

[Morphometric analysis of retinal arterioles in control and hypertensive population using adaptive optics imaging](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6786142/)

## Proposed method algorithm
1) Preprocessing
2) Vessel center curve detection
3) Border detection + WLR calculation

![3333](https://user-images.githubusercontent.com/62359460/166816821-7fca4046-c493-4d89-96b8-62b5b6db5419.png)
![2_vessel_detection](https://user-images.githubusercontent.com/62359460/166816819-8e986929-067a-48e4-950e-2954ef4a7098.png)
![3_wlr_calc](https://user-images.githubusercontent.com/62359460/166816987-aa0ced56-463e-4c05-beb9-5c3a2beb3ff9.png)

## Processing examples and results
Input image:

![1](https://user-images.githubusercontent.com/62359460/187036354-82e2841f-6324-4ee4-b248-428b22390b45.png)



1) Preprocessing

![1](https://user-images.githubusercontent.com/62359460/187036203-e1d26dc4-86c7-4b92-81ac-da7932af5456.png)

2) Vessel center curve detection

![2](https://user-images.githubusercontent.com/62359460/187036205-9336b7e6-6b6a-449c-940e-e0fe51b0733b.png)

Steps 1) and 2) on different images.<br> Left: input image <br> Right: vessel center curve

![3](https://user-images.githubusercontent.com/62359460/187036206-90cbc9b3-e221-43a9-9358-c6634f9a3171.png)

3) Cut center curve on multiple objects (white) and calculate centroids (red)

![4](https://user-images.githubusercontent.com/62359460/187036207-be87de78-f60d-4cdb-8233-6b962b9b0413.png)

4) Approximate center line by connecting centroids

![5](https://user-images.githubusercontent.com/62359460/187036209-642c4e09-e49a-4d1a-83dc-9fe75b3cd9e4.png)

5) Create ~500 perpendicular "scanning lines" (yellow) to the approximated center line (red)

![red](https://user-images.githubusercontent.com/62359460/187036748-a3e25e8a-0419-46c8-9972-80e351ea2751.png)

6) Detect and lumen (dark blue) and wall (light blue) borders

![asdasds](https://user-images.githubusercontent.com/62359460/187036758-ba2b6215-0565-414e-b622-1e4b6a8e1b01.png)

7) Final result for input image with heatmap indicating changing value of WLR across vessel

![7](https://user-images.githubusercontent.com/62359460/187036211-b34cc108-5f2f-497e-8cdf-ddcab25b2af9.png)





