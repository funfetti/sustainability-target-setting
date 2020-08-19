#!/usr/bin/env bash

# run chmod u+x orgInit-target.sh
# to actually execute: bash orgInit-target.sh
#
# get alias from user 
echo "this is the target setting package. name your sustainability scratch org:"
read sname

echo "your org alias is $sname"
echo creating your scratch org... 
sfdx force:org:create -f config/project-scratch-def.json -s -a $sname

# install 1.10
sfdx force:package:install -p 04t3k000001yv66AAA -w 20 

# PSL/Perms 
# using shane's plugins https://github.com/mshanemc/shane-sfdx-plugins

sfdx shane:user:psl -l User -g User -n sustain_app_SustainabilityCloudPsl
sfdx shane:user:psl -l User -g User -n InsightsInboxAdminAnalyticsPsl

sfdx force:user:permset:assign -n SustainabilityAnalytics
sfdx force:user:permset:assign -n SustainabilityAppAuditor
sfdx force:user:permset:assign -n SustainabilityAppManager
sfdx force:user:permset:assign -n SustainabilityCloud

sfdx shane:user:permset:assign -l User -g Integration -n SustainabilityAnalytics

#load data 
sfdx automig:load -d demo-data/ --concise --mappingobjects RecordType:DeveloperName,sustain_app__EmissionFactorElectricity__c:Name,sustain_app__EmissionFactorOther__c:Name,sustain_app__EmissionFactorScope3__c:Name

# alrighty lets push source 
sfdx force:source:push

# assign new dx'd perm sets
sfdx force:user:permset:assign -n GHG_Project_Accounting
sfdx force:user:permset:assign -n Sustainability_Offset
sfdx force:user:permset:assign -n Sustainability_Target_Setting

# open sesame
sfdx force:org:open 

# optional: create EA apps in the bkg
# sfdx analytics:app:create --templatename Sustainability
# sfdx analytics:app:create --templatename Sustainability_Audit -a
