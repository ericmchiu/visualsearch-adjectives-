function quit_practice()
global vs_figure 
global all_responses

text(200,550,'Practice section completed,','Fontsize', 50)
text(200,650,'please notify experimenter.','Fontsize', 50)
data = dir('subjects/practice*');
save(['subjects/practice' int2str(length(data)+1)],'all_responses','-ASCII');
pause(3)
close(vs_figure)