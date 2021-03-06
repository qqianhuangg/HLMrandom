install.packages("vctrs")
library(vctrs)
install.packages("haven")
library(haven)
install.packages("ggplot2")
library(ggplot2)
install.packages("car")
install.packages("psych")
install.packages("MASS")
install.packages("readxl")
install.packages("lmerTest")
install.packages("simr")
install.packages("magrittr")
library(car)
library(psych)
library(MASS)
library(lmerTest)
library(ggeffects)
library(simr)
library(magrittr)

#study 2 analysis by march 15 2020####
#import dataset at 12/16/2019 ###
setwd("/Users/thalassa/Dropbox/PHD2016to2020/Dissertation/Dissertation_study2_data/combined_for_final_analysis")#for mac
setwd("C:\\Users\\huang\\Dropbox\\PHD2016to2020\\Dissertation\\Dissertation_study2_data\\combined_for_final_analysis")#for windows

list.files(getwd())
data<-as.data.frame(read_spss("MERGED_all_769_computed_combine_no_truecontrol.sav"))

str(data)
names(data)
head(data)

#descriptive data####
describe(data$attitude)
describe(data$PME)
describe(data$behavioral_intent)

#convert to factor
is.factor(data$video_id)
data$video_id<-as.factor(data$video_id)

data$video_type<-as.factor(data$video_type)
is.factor(data$population)
data$population<-as.factor(data$population)
levels(data$population)<-c("Parents", 
                        "Young Adults")
levels(data$population)
data$population

#relevel
data$video_type <- relevel(data$video_type,"5")

#mixed model####
#when dv is PME####
data$video_type
mix.pme<-lmer(PME ~ video_type + (1|video_id), data=data)
summary(mix.pme)
names(data)

#when dv is PME and moderator is target audience population####
mix.ppl<-lmer(PME ~ video_type:population + (1|video_id), data=data)
summary(mix.ppl)


#when dv is knowledge in general####
mix.knowledge<-lmer(hpv_knowledge_all ~ video_type + (1|video_id), data=data)
summary(mix.knowledge)

#when dv is attitude. significant####
mix.attitude<-lmer(attitude ~ factor(video_type) + (1|video_id), data=data)
summary(mix.attitude)

#dv = behavioral intent, moderator=population
mix.beh.ppl<-lmer(behavioral_intent ~ video_type:population + (1|video_id), data=data)
summary(mix.beh.ppl)

#dv=behavioral intent, moderator=cues to action
names(data)
is.factor(data$cues_dummy)
data$cues_dummy<-as.factor(data$cues_dummy)
levels(data$cues_dummy)<-c("No", "Yes")
levels(data$cues_dummy)

mix.beh.cue<-lmer(behavioral_intent ~ video_type:cues_dummy + (1|video_id), data=data)
summary(mix.beh.cue)


#dv= behavioral intention#
mix.behavior<-lmer(behavioral_intent ~ video_type + (1|video_id), data=data)
summary(mix.behavior)
fixef(mix.behavior)

#one-way anova

mix.one<-lm(behavioral_intent  ~ video_type, data=data)
summary(mix.one)

#power analysis on linear mixed model####
install.packages("simr")
library(simr)
fixef(model1)["x"]
set.seed(123)

powerSim(mix.behavior)

power1 <- makeLmer(attitude ~ video_type + (1|video_id), fixef=fixef(mix.behavior), VarCorr= 0.001, sigma=2.98, data=data)

power1

sim<- powerSim(power1, nsim=100, test=fcompare(attitude ~ 1))
sim

?powerSim()

#qq plot####
plot(mix.behavior)  # looks alright, no patterns evident
qqnorm(resid(mix.attitude))
qqline(resid(mix.beh.ppl))  # points fall nicely onto the line - good!

#label the levels of video type
is.factor(data$video_type)
data$video_type<-as.factor(data$video_type)
levels(data$video_type)
data$video_type <- factor(data$video_type, labels = c("mixed", "talking head","animation","narrative","velfie"))
levels(data$video_type)


# ggplot2 for each DV####
#install wes anderson color palettes
install.packages("wesanderson")
library(wesanderson)

#PME #non-significant 
summary(mix.pme)
plot.pme <- ggeffects::ggpredict(mix.pme, terms = c("video_type"), type = "re")  # this gives overall predictions for the model
summary(plot.pme)

ggplot2::ggplot(plot.pme, aes(x = x, y = predicted,  fill = x)) +geom_col() +xlab("video_type")+ylab("Perceived Message Effectiveness (PME)")+ggtitle("Main Effects of Video Type") + ylim(0,6)+scale_fill_manual(values=wes_palette(n=5, name="Moonrise3"))+theme(legend.position = "none")+theme(axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold"))

#attitude
plot.attitude<-ggeffects::ggpredict(mix.attitude, terms = c("video_type"), type = "re")
                                                               
ggplot2::ggplot(plot.attitude, aes(x = x, y = predicted,  fill = x)) +geom_col() +xlab("video_type")+ylab("Attitude toward HPV vaccination")+ggtitle("Main Effects of Video Type on attitude") + ylim(0,7)+scale_fill_manual(values=wes_palette(n=5, name="FantasticFox1"))+theme(legend.position = "none")

#behavioral intention
plot.behavior<-ggeffects::ggpredict(mix.behavior, terms = c("video_type"), type = "re")

ggplot2::ggplot(plot.behavior, aes(x = x, y = predicted,  fill = x)) +geom_col() +xlab("video_type")+ylab(" Behavioral intent to HPV vaccination")+ggtitle("Main Effects of Video Type on behavioral intent") + ylim(0,6)+scale_fill_manual(values=wes_palette(n=5, name="Cavalcanti1"))+theme(legend.position = "none")

#knowledge

plot.know<-ggeffects::ggpredict(mix.knowledge, terms = c("video_type"), type = "re")

ggplot2::ggplot(plot.behavior, aes(x = x, y = predicted,  fill = x)) +geom_col() +xlab("video_type")+ylab("Knowledge about HPV and vaccination")+ggtitle("Main Effects of Video Type in increasing knowledge") + ylim(0,7)+scale_fill_manual(values=wes_palette(n=5, name="Darjeeling2"))+theme(legend.position = "none")

#dv=pme, moderator=population
wes_palettes
summary(mix.ppl)
plot.ppl<-ggeffects::ggpredict(mix.ppl, terms = c("video_type","population"), type = "re")
summary(plot.ppl)

ggplot2::ggplot(plot.ppl, aes(x = x, y = predicted,  fill = group)) +geom_col(position = "dodge2")+xlab("video_type")+ylab("PME")+ggtitle("Interaction between Video Type and Population on PME") + ylim(0,7)+scale_fill_manual(values=wes_palette(n=2, name="Moonrise2"))

#dv=behavior intention, moderator=population
summary(mix.beh.ppl)
plot.beh.ppl<-ggeffects::ggpredict(mix.beh.ppl, terms = c("video_type","population"), type = "re")
summary(plot.beh.ppl)

ggplot2::ggplot(plot.beh.ppl, aes(x = x, y = predicted,  fill = group)) +geom_col(position = "dodge2")+xlab("video_type")+ylab("Behavioral intention to HPV vaccination")+ggtitle("Interaction between Video Type and Population on behavioral intent") + ylim(0,7)+scale_fill_manual(values=wes_palette(n=2, name="Royal1"))


#dv=behavioral intention, moderator= cues to action
summary(mix.beh.cue)
plot.beh.cue<-ggeffects::ggpredict(mix.beh.cue, terms = c("video_type","cues_dummy"), type = "re")
summary(plot.beh.cue)

ggplot2::ggplot(plot.beh.cue, aes(x = x, y = predicted,  fill = group)) +geom_col(position = "dodge2")+xlab("video_type")+ylab("Behavioral intention to HPV vaccination")+ggtitle("Interaction between Video Type and Cues to Action on behavioral intent") + ylim(0,7)+scale_fill_manual(values=wes_palette(n=2, name="Darjeeling1"))

wes_palettes


# plot 1: line and dot
#behavioral intention across parents and young adults
names(data)
data %>% 
  ggplot() +
  aes(x = video_type, color = population, group = population, y = behavioral_intent) +
  stat_summary(fun.y  = mean, size=3, geom = "point") +
  stat_summary(fun.y = mean, size=1, geom = "line")



#plot 2: bar plot

apatheme=theme_bw()+
  theme(panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        panel.border=element_blank(),
        axis.line=element_line(),
        text=element_text(family='Times'))
dodge = position_dodge(width=0.9)

ggplot(data, aes(x = video_type, y = attitude, fill = population))+
  stat_summary(fun.y = mean,
               geom = "bar")+
  ylab('PME')+
  scale_fill_brewer(palette = "Blues")



#study 1: crosstab####

#box plot with confidence interval
is.factor(data$video_type)
data$video_type<-as.factor(data$video_type)
data$video_id<- as.factor(data$video_id)
names(data)
data$pop<-as.factor(data$population)
is.factor(data$pop)
levels(data$pop)<-c("parents", "college")
levels(data$pop)

ggplot(data, aes(x=video_type, y=attitude, colour=video_type))+geom_boxplot()


#color plot: attitude by need for cognition all

(colour_plot <- ggplot(data, aes(x = nfc_all, y = attitude, colour = video_type)) +
    geom_point(size = 2) +
    theme_classic() +
    theme(legend.position = "none"))

#color plot: attitude by need for cognition by video types
(split_plot <- ggplot(aes(nfc_all, attitude), data = data) + 
    geom_point() + 
    facet_wrap(~ video_type) + # create a facet for each video condition
    xlab("need for cognition") + 
    ylab("attitude"))



#using study 1 data only####
install.packages("ggstatsplot")
library(ggstatsplot)

setwd("/Users/thalassa/Dropbox/Dissertation/Dissertation_study1_videocoding")#for mac
setwd("C:\\Users\\huang\\Dropbox\\Dissertation\\Dissertation_study1_videocoding")#for windows
list.files()
study1<-read_sav("study1_videos_coded_variables.sav" )
str(study1)
names(study1)
is.data.frame(study1)
study1$video_type<-as.factor(study1$video_type)

is.factor(study1$video_type)
levels(study1$video_type)<-c("talking-head","animation", "narrative", "velfie", "mixed")
levels(study1$video_type)
study1$video_type<-relevel(study1$video_type, ref="mixed")
table(study1$video_type)
study1$video_type
table(study1$video_type, study1$Source)
#source as factor
study1$Source<-as.factor(study1$Source)
levels(study1$Source)
levels(study1$Source)<-c("Hospital/clinic/governmental agency", 
                         "Private account",
                         "Pharmarceutical",
                         "Non-profit organization")
levels(study1$Source)


#pie plot for source by video type#
install.packages("ggstatsplot")
library(ggstatsplot)

set.seed(123)
levels(study1$Source)

ggstatsplot::ggpiestats(
  data = study1,
  x = Source,
  y = video_type,
  title = "Source type by video type", # title for the plot
  legend.title = "Source of Video", # title for the legend 
  messages = FALSE
)

#pie plot for video type and target audience type
names(study1)
study1$Targetauidence<-as.factor(study1$Targetauidence)
levels(study1$Targetauidence)
levels(study1$Targetauidence)<-c("Parents of boys",
                                 "parents of girls",
                                 "Parents of boys or girls",
                                 "Female college students",
                                 "Male college students",
                                 "General college students",
                                 "Unspecified")
levels(study1$Targetauidence)

#pie plot for target audience and video type

ggstatsplot::ggpiestats(
  data = study1,
  x = Targetauidence,
  y = video_type,
  conf.level = 0.95, # confidence interval for effect size measure
  title = "Composition of target audience by video type", # title for the plot
  stat.title = "interaction: ", # title for the results
  legend.title = "Target Audience", # title for the legend
  factor.levels = c("1=Parents of boys", "2= parents of girls", "3 = Parents of boys or girls","4= Female college students", "5= Male college students",  "6= General college students","8= Unspecified"), # renaming the factor level names (`x`)
  facet.wrap.name = "No. of cylinders", # name for the facetting variable
  slice.label = "counts", # show counts data instead of percentages
  package = "ggsci", # package from which color palette is to be taken
  palette = "default_jama", # choosing a different color palette
  messages = FALSE # turn off messages and notes
)

#DO NOT USE: another pie plot with percentage####
head(study1)
study1$video_type

set.seed(123)
ggstatsplot::grouped_ggpiestats(
  dplyr::filter(
    .data = study1,
    video_type %in% c("talking-head", "animation", "narrative", "velfie","mixed")  
    ),
  x = Source,
  grouping.var = video_type, # grouping variable
  title.prefix = "XXX", # prefix for the facetted title
  label.text.size = 2, # text size for slice labels
  slice.label = "both", # show both counts and percentage data
  perc.k = 1, # no. of decimal places for percentages
  messages = FALSE,
  nrow = 3,
  title.text = "Composition of video sources by video type"
)



# bar plot:did not work on mac but works on PC. don't know why
# for reproducibility
set.seed(123)
str(ggstatsplot::movies_long)
sample1<-ggstatsplot::movies_long[,c(7:8)]
str(sample1)
install.packages("hrbrthemes")
library(hrbrthemes)

# plot
ggstatsplot::ggbarstats(
  data = ggstatsplot::movies_long,
  x = mpaa,
  y = genre,
  sampling.plan = "jointMulti",
  title = "MPAA Ratings by Genre",
  xlab = "movie genre",
  perc.k = 1,
  x.axis.orientation = "slant",
  ggtheme = hrbrthemes::theme_modern_rc(),
  ggstatsplot.layer = FALSE,
  ggplot.component = ggplot2::theme(axis.text.x = ggplot2::element_text(face = "italic")),
  palette = "Set2",
  messages = FALSE
)

#implementation####

names(study1)
str(study1)
study1$Agegroup<-as.factor(study1$Agegroup)
levels(study1$Agegroup)

# plot
ggstatsplot::ggbarstats(
  data = study1,
  x = video_type,
  y = Source,
  sampling.plan = "jointMulti",
  title = "Source by Video type",
  xlab = "Source",
  perc.k = 1,
  x.axis.orientation = "slant",
  ggtheme = hrbrthemes::theme_modern_rc(),
  ggstatsplot.layer = FALSE,
  ggplot.component = ggplot2::theme(axis.text.x = ggplot2::element_text(face = "italic")),
  palette = "Set2",
  messages = FALSE
)


# bar plot for continuous variables####
# for reproducibility
set.seed(123)
?set.seed()
str(study1)

# plot with mean and curve####
ggstatsplot::grouped_gghistostats(
  data = dplyr::filter(
    .data = study1,
    video_type %in% c("talking-head", "animation", "narrative", "velfie","mixed")
  ),
  x = Qualityofthevideo,
  xlab = "Movies budget (in million US$)",
  type = "robust", # use robust location measure
  grouping.var = video_type, # grouping variable
  normal.curve = TRUE, # superimpose a normal distribution curve
  normal.curve.color = "green",
  title.prefix = "Movie genre",
  ggtheme = ggthemes::theme_tufte(),
  ggplot.component = list( # modify the defaults from `ggstatsplot` for each plot
    ggplot2::scale_x_continuous(breaks = seq(0, 5, 1), limits = (c(0, 5)))
  ),
  messages = FALSE,
  nrow = 2,
  title.text = "Video quality by video type"
)

#post-hoc ANOVA analysis####
install.packages("multcomp")
library(multcomp)
??multcomp
names(data)

#video type on knowledge 
names(data)
data$video_type <- relevel(data$video_type, ref = "5")
levels(data$video_type)
is.factor(data$video_type)

mix.knowledge<-lmer(hpv_knowledge_all ~ video_type + (1|video_id), data=data)

summary(mix.knowledge)
summary(glht(mix.knowledge, linfct = mcp(video_type = "Tukey")), test =  adjusted("holm"))

#video type on PME

mix.pme<-lmer(PME ~ video_type + (1|video_id), data=data)
summary(mix.pme)
summary(glht(mix.pme, linfct = mcp(video_type = "Tukey")), test =  adjusted("holm"))


#video and population on PME
is.factor(data$population)
data$population<-as.factor(data$population)
mix.pme.ppl<-lmer(PME ~ video_type*population + (1|video_id), data=data)
summary(mix.pme.ppl)
summary(glht(mix.pme.ppl, linfct = mcp(video_type = "Tukey")),
        test =  adjusted("holm"))

#parents only
mix.pme1<-lmer(PME ~ video_type + (1|video_id), data=data1)
summary(mix.pme1)

summary(glht(mix.beh1, linfct = mcp(video_type = "Tukey")), test =  adjusted("holm"))

#young people only
mix.pme2<-lmer(PME ~ video_type + (1|video_id), data=data2)
summary(mix.pme2)

summary(glht(mix.beh2, linfct = mcp(video_type = "Tukey")), test =  adjusted("holm"))




#video and credibility
names(data)
mix.credibility<-lmer(message_credibility ~ video_type + (1|video_id), data=data)
summary(mix.credibility)
summary(glht(mix.credibility, linfct = mcp(video_type = "Tukey")),
        test =  adjusted("holm"))


#video and attitude
is.data.frame(data)
data$video_type<-as.factor(data$video_type)
str(data)
names(data)
mix.attitude<-lmer(attitude ~ video_type + (1|video_id), data=data)
summary(mix.attitude)

summary(glht(mix.attitude, linfct = mcp(video_type = "Tukey")), test =  adjusted("holm"))

#post-hoc behavioral intentions
mix.beh<-lmer(behavioral_intent ~ video_type*population + (1|video_id), data=data)
summary(mix.beh)

summary(glht(mix.beh, linfct = mcp(video_type = "Tukey")), test =  adjusted("holm"))
summary(glht(mix.beh, linfct = mcp(population = "Tukey")), test =  adjusted("holm"))

#parents only
mix.beh1<-lmer(behavioral_intent ~ video_type + (1|video_id), data=data1)
summary(mix.beh1)

summary(glht(mix.beh1, linfct = mcp(video_type = "Tukey")), test =  adjusted("holm"))

#young people only
mix.beh2<-lmer(behavioral_intent ~ video_type + (1|video_id), data=data2)
summary(mix.beh2)

summary(glht(mix.beh2, linfct = mcp(video_type = "Tukey")), test =  adjusted("holm"))


#post-hoc: cues to action and video type on behavorial intention
is.factor(data$cues_dummy)
data$cues_dummy<-as.factor(data$cues_dummy)
levels(data$cues_dummy)

mix.beh2<-lmer(behavioral_intent ~ video_type*cues_dummy + (1|video_id), data=data)
summary(mix.beh2)
summary(glht(mix.beh2, linfct = mcp(cues_dummy = "Tukey")), test =  adjusted("holm"))

#divide the dataset into two based on audience type
data1<-data[which(data$population == 1),]#parents
data2<-data[which(data$population==2),]#young people who vaccinate for themselves

#parents only
mix.cues1<-lmer(behavioral_intent ~ video_type + (1|video_id), data=data1)
summary(mix.cues1)

summary(glht(mix.beh1, linfct = mcp(video_type = "Tukey")), test =  adjusted("holm"))

#young people only
mix.cues2<-lmer(behavioral_intent ~ video_type + (1|video_id), data=data2)
summary(mix.beh2)

summary(glht(mix.beh2, linfct = mcp(video_type = "Tukey")), test =  adjusted("holm"))



#exploratory analysis: number of argument
data$argument_density<-data$Numberofarguments/data$lengthofvideo
describe(data$argument_density)

unique(data$video_id)

       