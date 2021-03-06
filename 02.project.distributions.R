#drafted by Jeremy VanDerWal ( jjvanderwal@gmail.com ... www.jjvanderwal.com )
#GNU General Public License .. feel free to use / distribute ... no warranties

################################################################################
#define directories
work.dir = '~/working/NARP_birds/models/'
mxe.dir = '~/Climate/CIAS/Australia/5km/bioclim_mxe/'
maxent.jar = "~/working/NARP_birds/maxent.jar"

################################################################################
#list the projections, cycle thorugh them and project the models onto them
proj.list = list.files(mxe.dir) #list the projections
proj.list = c('1990',proj.list[intersect(grep('2085',proj.list),grep('RCP',proj.list))]) #subset it to simply current and 2080 data

species = list.files(work.dir) #get a list of species

#cycle through each of the species
for (spp in species) {
	spp.dir = paste(work.dir,spp,'/',sep=''); setwd(spp.dir) #set the working directory to the species directory
	zz = file('02.project.models.sh','w') ##create the sh file
		cat('#!/bin/bash\n',file=zz)
		cat('cd $PBS_O_WORKDIR\n',file=zz)
		cat('module load java\n',file=zz)
		dir.create('output/ascii/',recursive=TRUE) #create the output directory for all maps
		#cycle through the projections
		for (tproj in proj.list) cat('java -mx1024m -cp ',maxent.jar,' density.Project ',spp.dir,'output/',spp,'.lambdas ',mxe.dir,tproj,' ',spp.dir,'output/ascii/',tproj,'.asc fadebyclamping nowriteclampgrid\n',sep="",file=zz)
		cat('gzip ',spp.dir,'output/ascii/*asc\n',sep='',file=zz)
	close(zz) 

	#submit the script
	system('qsub -m n 02.project.models.sh')
}
