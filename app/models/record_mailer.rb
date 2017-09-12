# -*- encoding : utf-8 -*-
# Only works for documents with a #to_marc right now. 
class RecordMailer < ActionMailer::Base
  helper LibraryHoldingsHelper


  # Email a record to a user
  def email_record(documents, details, url_gen_params)
    #raise ArgumentError.new("RecordMailer#email_record only works with documents with a #to_marc") unless document.respond_to?(:to_marc)
        
    subject = I18n.t('blacklight.email.text.subject', :count => documents.length, :title => (documents.first.to_semantic_values[:title] rescue 'N/A') )

    @documents      = documents
    @message        = details[:message]
    @url_gen_params = url_gen_params

    mail(:to => details[:to],  :subject => subject, :from => 'libref@linnbenton.edu')
  end
  
  # Text a record to a user
  def sms_record(documents, details, url_gen_params)
    @documents      = documents
    @url_gen_params = url_gen_params
    mail(:to => details[:to], :subject => "LBCC Library item", :from => 'libref@linnbenton.edu')
  end

end
