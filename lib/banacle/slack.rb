module Banacle
  module Slack
    Response = Struct.new(:response_type, :replace_original, :text, :attachments, keyword_init: true) do
      class ValidationFailed < StandardError; end

      def initialize(*args)
        super
        self.replace_original = true if self.replace_original.nil?
        self.attachments ||= []
        self.validate!
        self
      end

      def validate!
        # TODO
      end

      def as_json
        self.to_h.tap { |h| h[:attachments] = h[:attachments].map(&:as_json) }
      end

      def to_json
        as_json.to_json
      end
    end

    Attachment = Struct.new(:text, :fallback, :callback_id, :color, \
                            :attachment_type, :actions, keyword_init: true) do
      class ValidationFailed < StandardError; end

      def initialize(*args)
        super
        self.actions ||= []
        self.validate!
        self
      end

      def validate!
        # TODO
      end

      def as_json
        self.to_h.tap { |h| h[:actions] = h[:actions].map(&:as_json) }
      end
    end

    Action = Struct.new(:name, :text, :style, :type, :value, keyword_init: true) do
      class ValidationFailed < StandardError; end

      def self.approve_button
        self.build_button('approve', style: 'primary')
      end

      def self.reject_button
        self.build_button('reject', style: 'danger')
      end

      def self.cancel_button
        self.build_button('cancel')
      end

      def self.build_button(value, style: 'default')
        self.build(value, style, 'button')
      end

      def self.build(value, style, type)
        self.new(name: value, text: value.capitalize, style: style, type: type, value: value)
      end

      def initialize(*args)
        super
        self.validate!
        self
      end

      def validate!
        # TODO
      end

      def approved?
        self.value == 'approve'
      end

      def rejected?
        self.value == 'reject'
      end

      def cancelled?
        self.value == 'cancel'
      end

      def as_json
        self.to_h
      end
    end
  end
end
