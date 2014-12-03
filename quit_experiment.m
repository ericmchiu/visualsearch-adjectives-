function quit_experiment()
global vs_figure 
global all_responses

text(100,100,'The Experiment is complete. Thank You!','Fontsize', 50)
data = dir('subjects/subject*');
save(['subjects/subject' int2str(length(data)+1)],'all_responses','-ASCII');
pause(3)
close(vs_figure)