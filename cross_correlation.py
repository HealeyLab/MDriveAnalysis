# -*- coding: utf-8 -*-
"""
Created on Sat Jun 23 21:58:10 2018
@author: Dell
"""
#from elephant.conversion import BinnedSpikeTrain
#from quantities import ms
#from neo.core import SpikeTrain

import glob
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import re
import scipy.io as sio
import seaborn as sns
from pypaths.pypaths import Pypath
pp = Pypath()
'''Sort into a data frame with fields
Binned data    Channel    Class
List           int        int
Run this script before going about using our CLI for data analysis.
'''
def make_df():
    # \left_ncm_2_baseline_180329_183406
    #res = [file for file in os.listdir(path) if re.search(r'(abc|123|a1b).*\.txt$', file)]
    df = pd.DataFrame(columns=['trains','channel', 'unit'])
    # Test data directory
    path = r'G:\HealeyDataAndScripts\mdrivemdialysis_PILOT_1' #windows
    
    path = pp.to_native(path)
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
    df.to_pickle(path+'df.pkl')
    # unpickled_df = pd.read_pickle("./dummy.pkl")

def make_correlograms():
#    df = pd.read_pickle(r'G:\HealeyDataAndScripts\mdrivemdialysis_PILOT_1\df.pkl')
    df = pd.read_pickle(r'/media/alp/Local Disk/HealeyDataAndScripts/mdrivemdialysis_PILOT_1/df.pkl')
    ### Get base filename info
    fileinfo = df.loc[[1], 'channel'].tolist()[0].split('\\')
    filepath = pp.join(fileinfo[:-1], win=True)
    filename = fileinfo[-1]
    '''['G:', 'HealeyDataAndScripts', 'mdrivemdialysis_PILOT_1', 'left_ncm_180329_181407', 'times_left_ncm_180329_181407_1.mat']'''
    
    cmd = ''
    while cmd not in ['q', 'quit']:
        cmd = input('Please input channel numbers separated by spaces (e.g., \'3\' \'14\')\n')
        if re.match('\d\d? \d\d?', cmd): # means optional second digit
            
            args = cmd.split() # should be list of two numbers
            chan1 = args[0]
            chan2 = args[1]
            
            def get_trains(chan):
                newfilename = filename[:-5] + chan2 + '.mat' # [:-5] is minus #.mat (# always equals 1)
                chan_file = pp.join([filepath, newfilename], win=True)
                trains = np.array(df.loc[df['channel']==chan_file, ['trains']])
                return np.array([x[0] for x in trains])
            
            train1 = get_trains(chan1)
            train2 = get_trains(chan2)
            
            cov_list = np.empty(0)
            for i in range(len(train1)):
                cov_list = np.append(cov_list, (train1[i] - train2))
            
            return cov_list
            '''
            from elephant.conversion import BinnedSpikeTrain
            cov_matrix = covariance(BinnedSpikeTrain([st1, st2], binsize=5*ms))
            '''
def make_all_correlograms(numchan=32, filepath=r'/media/alp/Local Disk/HealeyDataAndScripts/mdrivemdialysis_PILOT_1/df.pkl'):
    df = pd.read_pickle(filepath)
    ### Get base filename info
    fileinfo = df.loc[[1], 'channel'].tolist()[0].split('\\')
    filepath = pp.join(fileinfo[:-1], win=True)
    filename = fileinfo[-1]
    
    def get_trains(chan):
        newfilename = filename[:-5] + chan2 + '.mat' # [:-5] is minus #.mat (# always equals 1)
        chan_file = pp.join([filepath, newfilename], win=True)
        trains = np.array(df.loc[df['channel']==chan_file, ['trains']])
        return np.array([x[0] for x in trains])
    
    all_trains = np.empty(0)
    for i in range(numchan):
        np.concatenate(all_trains, get_trains(i))
    
    
    for row in range(numchan-1):
        for col in range(row+1, numchan-1):
            cov_list = np.empty(0)    
            for i in range(len(all_trains[row])):
                cov_list = np.append(cov_list, (all_trains[row][i] - all_trains[col]))
                    
            subplot(numchan-1, numchan-1, (numchan-1)*row + col)
            plt.
    
if __name__ == "__main__":
    cmd = ''
    while cmd != 'q' and cmd != 'quit':
        cmd = input('new df or load old one? (all/new/old/quit/q)\n')
        if cmd == 'new':
            make_df()
        elif cmd == 'old':
            cov_list = make_correlograms()
            plt.close()
            plt.hist(cov_hist, bins=range(-50, 51, 5))
            plt.show()
#            plt.xlim((-50, 50))
            plt.ginput(1)
        elif cmd=='all':
            make_all_correlograms()
