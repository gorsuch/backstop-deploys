module Backstop
  module Deploys
    module Config
      extend self

      def env!(key)
        ENV[key] || raise("#{key} not found in ENV")
      end

      def librato_email
        env!('LIBRATO_EMAIL')
      end

      def librato_key
        env!('LIBRATO_KEY')
      end
    end
  end
end
