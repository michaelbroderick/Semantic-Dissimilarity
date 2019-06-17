function [words, semanticDissim,wordVectors, fullStopPos,WPS]=calculateSemanticDissim(filename, funcWords, conceptRowsC, datM2)

% Generates semantic dissimilarity values for all content words in a text
% files. Based on their preceding sentential context (Broderick et al,
% Current Biology 2018).
%
% Michael Broderick (2019)
%--------------------------------------------------------
%   INPUT
% filename: Directory where text files is stored
% funcWords: Function words to remove
% conceptRowsC: Dictionary of words. Index corresponds to the word vector
% in datM2
% datM2: Word vectors
%
%   OUTPUT
%  words: Cell array of words
%  semanticDissim: Dissimilarity values
%  wordVectors: Corresponding word vectors
%  fullStopPos: Indices corresponding to words where full stops occur
%----------------------------------------------


%Read in the Text
[ words,fsp ] = readText( filename,1 );
[ words1 ] = readText( filename,0 );
fullStopPos=[];
WPS=[];
punc2=[".",'!','?'];

% Remove Function Words
%load('functionWords');
removeW=find(ismember(words,funcWords) | ~ismember(words,conceptRowsC));

keepW=setdiff(1:length(words),removeW)';
xx=intersect(removeW,fsp);
for i=1:length(xx) 
    tmp=xx(i)-keepW;
    tmp(tmp<0)=[];
    try words1{xx(i)-min(tmp)}=[words1{xx(i)-min(tmp)} '.'];
    catch
    end
end
words1(removeW)=[];
words(removeW)=[];

for i=1:length(words1)
    if ismember(words1{i}(end),punc2)
        fullStopPos=[fullStopPos;i];
    end
end

for i=1:length(words)
wordVectors(i,:)=datM2(find(ismember(conceptRowsC,words{i})),:);
end

semanticDissim=zeros(length(words),1);
aveVec=wordVectors(1,:);
sumVec=wordVectors(1,:);

count=1;
for i=2:length(words)
   
    semanticDissim(i,1)=1.00001-corr(wordVectors(i,:)',aveVec');
    
    if ismember(i-1,fullStopPos)
        aveVec=wordVectors(i,:);
        sumVec=wordVectors(i,:);

        WPS=[WPS count];
        count=1;
        
    else
        count=count+1;
        sumVec=(sumVec+wordVectors(i,:));
       aveVec=sumVec./count;
        
    end
    
    
end

end