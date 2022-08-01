local model1 ln_views	careerlength careerlength_sq i.debut i.female
local model2 ln_views	careerlength careerlength_sq i.debut i.female i.agency_code
local model3 ln_views	careerlength careerlength_sq i.debut i.female i.agency_code i.author_code##i.contenttype_code

local model1 ln_views	ln_careerlength ln_careerlength_sq i.debut
local model2 ln_views	ln_careerlength ln_careerlength_sq i.debut i.female
local model3 ln_views	ln_careerlength ln_careerlength_sq i.debut i.agency_code
local model4 ln_views	careerlength careerlength_sq i.debut i.female i.agency_code i.author_code##i.contenttype_code

local model1 views	careerlength careerlength_sq i.debut
local model2 views	careerlength careerlength_sq i.debut i.female
local model3 views	careerlength careerlength_sq i.debut i.agency_code
local model4 views	careerlength careerlength_sq i.debut i.female i.agency_code i.author_code##i.contenttype_code

local modela1 views 	i.debut careerlength 
local modela2 views 	i.debut careerlength i.female
local modela3 views 	i.debut careerlength i.female b1.agency_code 
local modela4 views 	i.debut careerlength i.author_code
local modelb1 views 	i.debut careerlength careerlength_sq 
local modelb2 views 	i.debut careerlength careerlength_sq i.female
local modelb3 views 	i.debut careerlength careerlength_sq i.female b1.agency_code 
local modelb4 views 	i.debut careerlength careerlength_sq i.author_code

