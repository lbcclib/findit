# An analytics table that records salient
# details about user searches
class SearchFingerprint < ActiveRecord::Base
  visitable

  after_create :create_user_fingerprint

  private

  # Record the salient details of a search
  def create_user_fingerprint
    unless self.visit.nil?
      if self.visit.has_attribute? 'id'
        fingerprint_already_exists = UserFingerprint.find_by_visit_id(self.visit.id)
        unless fingerprint_already_exists
          UserFingerprint.create do |uf|
            unless self.visit.ip.empty?
              if ['127.0.0.1', '0:0:0:0:0:0:0:1'].include? self.visit.ip
                uf.bot_visitor = false
                uf.in_district = true
                uf.localhost = true
                uf.on_campus = true
              elsif (/^(192\.168|140.211.14|173.164.83.205|75.148.94.53)[.0-9]*/ =~ self.visit.ip)
                uf.bot_visitor = false
                uf.in_district = true
                uf.localhost = false
                uf.on_campus = true
              else
                uf.localhost = false
                uf.on_campus = false
              end
            end
            if self.visit.postal_code
              uf.postal_code = self.visit.postal_code
              if ['97321', '97322', '97324', '97326', '97327', '97329', '97330', '97331', '97333', '97335', '97336', '97339', '97345', '97346', '97348', '97350', '97355', '97358', '97360', '97361', '97370', '97374', '97377', '97383', '97386', '97389', '97446', '97456'].include? self.visit.postal_code
                uf.in_district = true
              else
                uf.in_district = false
              end
            end
          end
        end
      end
    end
  end

end
