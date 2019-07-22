/**
 * Trigger used to combine all comments into custom fields.
 * 
 * @author      Jessica Amposta
 * @since       6/28/19
 **/


trigger ConcatAllComments on CampaignMember (after insert, after update, after delete, after undelete) {

//If the event is insert or undelete, this list takes new values or else it takes old values
List<CampaignMember> CampaignMemberList = (Trigger.isInsert|| Trigger.isUnDelete) ? Trigger.new : Trigger.old;

//Stores the Campaign Member's Campaign ID that is associated with each child record
List<Id> CampaignIds = new List<Id>();


//Loop through the Campaign Member records to store the Campaign Id values
for (CampaignMember CMs: CampaignMemberList) {
CampaignIds.add(CMs.CampaignId);
}

//Sub-query to get the campaigns and all its Child Records where Id is equal to the Ids stored in CampaignIds
List<Campaign> CampaignList = [select Id, (select CampaignId, Rating_Reason_Suggestions__c, Survey_Sent__c, Sentiment_Analysis__c from CampaignMembers), Send_NPS__c from Campaign where Id in: CampaignIds];

//This is to concat all of the comment and suggestions from every campaign member of an event
//Loop through the list and store the Child Records as a string of values in a Long Text Area Field i.e. NPS_All_Comments__c
for (Campaign Cmpgn: CampaignList) {
    if(Cmpgn.Send_NPS__c==TRUE && Cmpgn.CampaignMembers.size()> 0) {
    
		if(string.valueof(Cmpgn.CampaignMembers[0].Rating_Reason_Suggestions__c)!=null && Cmpgn.CampaignMembers[0].Survey_Sent__c == TRUE) {
           Cmpgn.NPS_All_Comments__c = string.valueOf(Cmpgn.CampaignMembers[0].Rating_Reason_Suggestions__c);
           }
		else
           Cmpgn.NPS_All_Comments__c = '';
         
      
		for(integer i=1; i<Cmpgn.CampaignMembers.size(); i++){
       
            if(Cmpgn.CampaignMembers[i].Survey_Sent__c == FALSE || string.valueOf(Cmpgn.CampaignMembers[i].Rating_Reason_Suggestions__c) == null) {
                    Cmpgn.NPS_All_Comments__c = Cmpgn.NPS_All_Comments__c;
            }
            else
                    Cmpgn.NPS_All_Comments__c = Cmpgn.NPS_All_Comments__c + '\n' + string.valueOf(Cmpgn.CampaignMembers[i].Rating_Reason_Suggestions__c);
        }    
  }
	else
		Cmpgn.NPS_All_Comments__c=null;
    
 }


//This is to compile and categorize the comments after the sentiment analysis has been done    
//Loop through the list and store the Child Records as a string of values in a Long Text Area Field i.e. SentAn_Negative_Comments__c, SentAn_Neutral_Comments__c, SentAn_Positive_Comments__c    
for (Campaign Cmpgn: CampaignList) {
    if(Cmpgn.Send_NPS__c==TRUE && Cmpgn.CampaignMembers.size()> 0) {
    
       Cmpgn.SentAn_Positive_Comments__c='';
       Cmpgn.SentAn_Negative_Comments__c='';
       Cmpgn.SentAn_Neutral_Comments__c='';
        
       if(string.valueof(Cmpgn.CampaignMembers[0].Sentiment_Analysis__c) == 'POSITIVE') {
           Cmpgn.SentAn_Positive_Comments__c = string.valueOf(Cmpgn.CampaignMembers[0].Rating_Reason_Suggestions__c);
           }
       else if(string.valueof(Cmpgn.CampaignMembers[0].Sentiment_Analysis__c) == 'NEGATIVE') {
           Cmpgn.SentAn_Negative_Comments__c = string.valueOf(Cmpgn.CampaignMembers[0].Rating_Reason_Suggestions__c);
           }
       else if(string.valueof(Cmpgn.CampaignMembers[0].Sentiment_Analysis__c) == 'NEUTRAL') {
           Cmpgn.SentAn_Neutral_Comments__c = string.valueOf(Cmpgn.CampaignMembers[0].Rating_Reason_Suggestions__c);
           }
         
        for(integer i=1; i<Cmpgn.CampaignMembers.size(); i++){
            
            Cmpgn.SentAn_Positive_Comments__c = Cmpgn.SentAn_Positive_Comments__c;
            Cmpgn.SentAn_Negative_Comments__c = Cmpgn.SentAn_Negative_Comments__c;
            Cmpgn.SentAn_Neutral_Comments__c =  Cmpgn.SentAn_Neutral_Comments__c;

            
            if (string.valueof(Cmpgn.CampaignMembers[i].Sentiment_Analysis__c) == 'POSITIVE') {
                Cmpgn.SentAn_Positive_Comments__c = Cmpgn.SentAn_Positive_Comments__c + '\n' + string.valueOf(Cmpgn.CampaignMembers[i].Rating_Reason_Suggestions__c);
            }
            else if (string.valueof(Cmpgn.CampaignMembers[i].Sentiment_Analysis__c) == 'NEGATIVE') {
                Cmpgn.SentAn_Negative_Comments__c = Cmpgn.SentAn_Negative_Comments__c + '\n' + string.valueOf(Cmpgn.CampaignMembers[i].Rating_Reason_Suggestions__c);
            }
            else if (string.valueof(Cmpgn.CampaignMembers[i].Sentiment_Analysis__c) == 'NEUTRAL') {
                Cmpgn.SentAn_Neutral_Comments__c = Cmpgn.SentAn_Neutral_Comments__c + '\n' + string.valueOf(Cmpgn.CampaignMembers[i].Rating_Reason_Suggestions__c);
            }         
        }
    }
    else {
        Cmpgn.SentAn_Positive_Comments__c=null;
        Cmpgn.SentAn_Negative_Comments__c=null;
        Cmpgn.SentAn_Neutral_Comments__c=null;    
    }
}
//Update The List
Update CampaignList;
}
