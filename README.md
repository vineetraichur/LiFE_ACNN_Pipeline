# LiFE_ACNN_Pipeline
This tool is currently being developed and not ready for use.

This tool is designed to map human white-matter fascicles using Diffusion-Weighted Imaging (DWI) data. There are a series of five steps in the DWI processing pipeline and the original scripts developed for this purpose are located here - https://github.com/brain-life   
Step 1, align T1 reference images to AC-PC plane: https://github.com/brain-life/app-autoalignacpc 
Step 2, preprocess the DWI and remove artifacts: https://github.com/brain-life/app-dtiinit  
Step 3, parcellate the brain: https://github.com/brain-life/app-freesurfer  
Step 4, apply tractography algorithms: https://github.com/brain-life/app-tracking    
Step 5, run Linear fascicle evaluation (LiFE): https://github.com/brain-life/app-life 

Laboratory of Neuro Imaging (LONI) - http://pipeline.loni.usc.edu/  
This tool has been developed in the LONI Pipeline workflow application. The LONI Pipeline is an application that allows users to easily describe their programs in a graphical user interface. Using the application's built-in features, users can create and execute complex workflows with relative ease. 

