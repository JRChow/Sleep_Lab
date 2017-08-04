function [pumpsOut, popOut] = getSubjectDataBART(theSub, session, subject, sessionV, pumpsIn, popIn)
%This program returns the subjects data from the entire pumps and pop data
%vectors.
%has the option to return a particular session (see ~=0) if statements
%or returns the entire vector of data for a subject accross sessions (set
%session = 0)
      
       
if (session ~=0)
   theSubIndex = find(subject==theSub);

   subSessionIndex = find(sessionV(theSubIndex) == session);

   pumpsOut = pumpsIn(theSubIndex(subSessionIndex));

   popOut = popIn(theSubIndex(subSessionIndex));

else
   theSubIndex = find(subject==theSub);

   subSessionIndex = find(sessionV(theSubIndex) > session);

   pumpsOut = pumpsIn(theSubIndex(subSessionIndex));

   popOut = popIn(theSubIndex(subSessionIndex));

end;

           
           
       
