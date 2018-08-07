# -*- coding: utf-8 -*-
"""
Created on Sat Jun 23 21:58:10 2018
@author: Dell
"""
from elephant.conversion import BinnedSpikeTrain
from quantities import ms
from neo.core import SpikeTrain

import glob
import pandas as pd
import numpy as np

import re

import pypaths.pypaths as pypaths
import scipy.io as sio


'''Sort into a data frame with fields
Binned data    Channel    Class
List           int        int
Run this script before going about using our CLI for data analysis.
'''
def make_df():
	# Test data directory
	pp = pypaths.Pypath()
	path = pp.to_native(r'G:\HealeyDataAndScripts\mdrivemdialysis_PILOT_1') #windows
	#path = r'/media/dan/Local Disk/HealeyDataAndScripts' #unix
	# \left_ncm_2_baseline_180329_183406
	
	#res = [file for file in os.listdir(path) if re.search(r'(abc|123|a1b).*\.txt$', file)]
	df = pd.DataFrame(columns=['trains','channel', 'unit'])
	
	for file in glob.iglob(pp.join([path,'**','times_*.mat']), recursive=True):
	    contents = sio.loadmat(file)
	    clust = contents['cluster_class']
	    
	
	    # Take single column (of times):
	    num_classes = max(clust[:,0])
	    # Checking number of cell classes
	    if num_classes < 1:
	        continue # stop executing somehow
	
	    for i in range(int(num_classes)):
	
	        # Logical indexing in Python!
	        ind = clust[:,0] == i
	
	        # getting only second column
	        class_times = clust[ind,1]
	
	        # array, final value
	#        if len(class_times) > 0:
	#            curr_train  = SpikeTrain(class_times * ms, class_times[-1])
	#        else:
	#            curr_train  = SpikeTrain(class_times * ms, 0)
	
	        df_temp = pd.DataFrame(
	                {'trains' : class_times, # was curr_train, but dataframes aren't 3D so might as well do this
	                 'channel' : file,
	                 'unit' : i})
	        df = pd.concat([df, df_temp])
	
	df.to_pickle(pp.join([path,'df.pkl']))
	# unpickled_df = pd.read_pickle("./dummy.pkl")

def make_correlograms():
	df = pd.read_pickle(r'G:\HealeyDataAndScripts\mdrivemdialysis_PILOT_1\df.pkl')
	pp = pypaths.Pypath()
	### Get base filename info
	fileinfo = df.loc[[1], 'channel'].tolist()[0].split('\\')
	filepath = fileinfo[:-1]
	filename = fileinfo[-1]
	'''['G:', 'HealeyDataAndScripts',
					'mdrivemdialysis_PILOT_1',
			       'left_ncm_180329_181407',
					'times_left_ncm_180329_181407_1.mat']'''
	
	cmd = ''
	while cmd not in ['q', 'quit']:
		cmd = input('Please input channel numbers separated by spaces (e.g., \'3\' \'14\')\n')
		if re.match('\d\d? \d\d?', cmd): # means optional second digit
			
			args = cmd.split() # should be list of two numbers
			chan1 = args[0]
			chan2 = args[1]
			
			for chan in [chan1, chan2]:
				newfilename = filename[:-5] + chan2 + '.mat' # [:-5] is minus #.mat (# always equals 1)
				chan_file = pp.join([pp.join(filepath),newfilename])
				trains = df[df['channel'] == chan_file]['trains']
				trains = np.array(trains)
			

			
	'''
    from elephant.conversion import BinnedSpikeTrain
    cov_matrix = covariance(BinnedSpikeTrain([st1, st2], binsize=5*ms))
    '''

if __name__ == "__main__":
	cmd = ''
	while cmd != 'q' and cmd != 'quit':
		cmd = input('new df or load old one? (new/old)\n')
		if cmd == 'new':
			make_df()
		elif cmd == 'old':
			make_correlograms()
		