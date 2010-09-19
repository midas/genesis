module Genesis
  module ActiveRecordExtensions
    def self.included( base )
      base.extend( ClassMethods )
      class << ActiveRecord::Base; alias_method_chain :method_missing, :create_or_update; end
    end

    module ClassMethods
      # Use all attributes to try and find a record.  If found returns the record.  Otherwise creates
      # and returns the record.
      #
      def create_or_update_by_all( attrs={} )
        attrs = extract_ar_object_ids( attrs )
        conditions = attrs
        record = find( :first, :conditions => conditions ) || self.new
        record.attributes = attrs
        record.save!
        record
      end

      # Use some attributes (the ones passed in as the find_by hash) to try and find a record.  If found
      # returns the record.  Otherwise creates and returns the record with all of the attributes (including
      # the ones in the find_by hash.)
      #
      def create_or_update_by_some( attrs={} )
        attrs = extract_ar_object_ids( attrs )
        conditions = attrs.delete( :find_by )
        raise 'You must provide a :find_by hash of attributes to search with, ie. :find_by => {:id => 1}' unless conditions
        attrs.merge!( conditions )
        record = find( :first, :conditions => conditions ) || self.new
        record.attributes = attrs
        record.save!
        record
      end

      def create_or_update( attrs={} )
        self.create_or_update_by( :id, attrs )
      end

      def create_or_update_by( field, attrs={} )
        attrs = extract_ar_object_ids( attrs )
        find_value = attrs[field]
        conditions = {field => find_value}
        record = find( :first, :conditions => conditions) || self.new
        record.attributes = attrs
        record.save!
        record
      end

      # Catches method missing exceptions and tries to write a custom find or update by method that uses the he field name
      # at the end of the method name as the find conditions.  Method must match pattern create_or_update_by_{attribute}
      #
      def method_missing_with_create_or_update( method_name, *args )
        if match = method_name.to_s.match(/create_or_update_by_([a-z0-9_]+)/)
          field = match[1].to_sym
          create_or_update_by(field, *args)
        else
          method_missing_without_create_or_update(method_name, *args)
        end
      end

      private

      def extract_ar_object_ids( attrs )
        # TODO: Fix this technique.  It current flattens any *_attributes => [...] effectively destroying it.
        # attrs = attrs.map do |attr,val|
        #   debugger if attr == :citations_attributes
        #   (attr.to_s.include?('_id') && val.is_a?( ActiveRecord::Base )) ? [attr,val.id] : [attr,val]
        # end
        #
        # Hash[*attrs.flatten]

        attrs.each do |attr,val|
          if attr.to_s.include?('_id') && val.is_a?( ActiveRecord::Base )
            attrs[attr] = val.id
          end
        end
      end
    end
  end
end