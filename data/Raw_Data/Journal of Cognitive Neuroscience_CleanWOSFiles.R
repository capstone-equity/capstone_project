setwd("File path") #this is the directory where you have your code and folder of text files
source("HelperFunctions.R")
library(bibliometrix)
library(rvest)
library(dplyr)

# Change to the names of your journal folders within project folder
journal_folders=c("journal_folder_name") #this folder contains your text files downloaded from WOS - in my case, I only downloaded JoCN metadata text files

for(i in journal_folders){
  # For each journal, find all data files within folder
  files=list.files(i)
  #data.frame=NULL
  
  this_df=convert2df(paste0(i,"/",files), dbsource = "wos", format = "plaintext");
  
  # #for(j in files){
  #  # j
  #   # For each file, read data in, convert to data frame, and concatenate
  # # this.data.frame=convert2df(paste0(i,"/",j), dbsource = "wos", format = "plaintext");#readFiles(paste0(i,"/",j))
  #   # this.data.frame=createdf(this.data.frame)
  #  
  #  # if(!is.null(data.frame)){
  #     #data.frame=merge(data.frame,this.data.frame,all=T,sort=F)
  #   #}else{
  data.frame=this_df
  # #  }
  # #}
  
  # Find article entries that don't have DOI but do have PubMed ID
  without.DOI=which((data.frame$DI=="" | is.na(data.frame$DI)) &
                      !is.na(data.frame$PM))
  
 # if(length(without.DOI)>0){

  #   # For articles with PubMed ID but no DOI - for some reason, we ended up going with 'NA's for the missing dois, I think because the PubMed sites weren't working for us. 
    # You could try to uncomment the code and try it if some are missing
    for(j in without.DOI){

    #   # Find relevant DOI from PMC id-translator website
     # this.pubmed=data.frame$PM[j]
      #turl=paste0("https://www.ncbi.nlm.nih.gov/pmc/utils/idconv/v1.0/?ids=",
      #            this.pubmed) 
      #xml=suppressWarnings(read_xml(turl,as_html=T)) 
      #doi=xml %>% html_nodes("record") %>% html_attr("doi")
      doi=NA
# #If PMC id-translator doesn't have it indexed... 
      if(is.na(doi)){ 
    #    # Try using pubmed website directly
     #   turl=paste0("https://pubmed.ncbi.nlm.nih.gov/",this.pubmed)
      #  html=read_html(turl) 
       # doi=html %>% html_nodes("meta[name='citation_doi']") %>%
        #  html_attr("content") 
      }

# If neither thing worked, just make it empty 
      doi=ifelse(!is.na(doi),doi,"")

## If it's not empty, enter the new DOI into data.frame 
     # if(nchar(doi)>0){
      #  data.frame$DI[j]=doi 
       # print(doi) 
    #  }

# Pause to space out pull requests 
     # Sys.sleep(2) 
  #  }
  }

# Select relevant variables # AF=authors, SO=journal, DT=article type,
#CR=reference list # TC=total citation, PD=month/day, PY=year, DI=DOI

# If more are needed, please add
  data.frame=data.frame %>% 
    select(PT,AU,BA,BE,GP,AF,BF,CA,TI,SO,SE,BS,LA,DT,CT,CY,CL,SP,HO,DE,ID,AB,C1,C3,RP,EM,RI,OI,FU,FP,FX,CR,NR,TC,Z9,U1,U2,PU,PI,PA,SN,EI,NB,Z9,U1,U2,Pu,PI,PA,SN,EI,BN,J9,JI,PD,PY,VL,IS,PN,SU,SI,MA,BP,EP,AR,DI,DL,D2,EA,PGWC,WE,SC,GA,PM,OA,HC,HP,DA,UT)

# Translate month/day to numeric month
  data.frame$PD=unlist(lapply(1:nrow(data.frame),get.date,pd=data.frame$PD))
  data.frame$PD=as.numeric(data.frame$PD)
#data.frame=data.frame[data.frame$PD%in%c(1:12),]

# Subset to only articles (i.e., remove editorial content etc.)
  without.type=which(data.frame$DT=="ARTICLE" | data.frame$DT=="REVIEW")
  #data.frame=data.frame[data.frame$DT%in%c("ARTICLE","REVIEW"),] #Article","Review"),]
data.frame=data.frame[without.type,]

# Standardize dois and reference lists to lowercase
data.frame$DI=tolower(data.frame$DI)
data.frame$CR=tolower(data.frame$CR)

# Optional: subset data by date #data.frame=data.frame[data.frame$PY>=1995,]

# Optional (would need to change code to be journal specific): # Locate DOIs
#that may have typos (WoS sometimes messes up DOIs)
#weirdindices=which(data.frame$DI!="" & !grepl("10.1038",data.frame$DI))
#weirddois=data.frame$DI[weirdindices]

# Save new data frame of this journal's complete data
  save(data.frame,file=paste0(i,"_df1_webofscience.RData")) 
}






