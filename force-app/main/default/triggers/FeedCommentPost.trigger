trigger FeedCommentPost on FeedComment (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        FeedItemHelper.feedCommentAfterInsertHandler(Trigger.new);
    }
}