xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.rss version: "2.0" do
  xml.channel do
    xml.title "WWWorkRemote job postings"
    xml.link job_postings_url
    xml.description "New active job postings from WWWorkRemote"
    @job_postings.each do |job|
      xml.item do
        xml.title "#{job.feed_company_name.presence || 'Unknown company'} — #{job.title.presence || 'Untitled posting'}"
        xml.link job_posting_url(job)
        xml.guid job_posting_url(job)
        xml.pubDate (job.published_at || job.created_at).rfc2822
        xml.description truncate(strip_tags(job.body.to_s), length: 500)
      end
    end
  end
end
