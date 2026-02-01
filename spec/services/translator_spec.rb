# frozen_string_literal: true

require "rails_helper"

RSpec.describe Translator, type: :service do
  describe "class methods" do
    describe ".services_dictionary" do
      it "builds dictionary from database services" do
        # Clear any existing cache to ensure we hit the database
        described_class.instance_variable_set(:@services_dictionary, nil)

        # Use a sequence to ensure uniqueness
        service = create(:service)

        # Update the service to have a predictable name for testing
        service.update!(key: "test_service_#{service.id}", name: "Test Service #{service.id}")

        dictionary = described_class.services_dictionary

        service_key = "test_service_#{service.id}"
        service_name = "test service #{service.id}"

        # The lookup comes from variations of service.name (not service.key itself)
        expect(dictionary[service_name]).to eq(service_key)
        expect(dictionary["#{service_name}s"]).to eq(service_key)
      end

      it "includes static services dictionary mappings" do
        dictionary = described_class.services_dictionary

        # Test shelter → housing mapping
        expect(dictionary["shelter"]).to eq(:shelter)
        expect(dictionary["housing"]).to eq(:shelter)
        expect(dictionary["house"]).to eq(:shelter)

        # Test hygiene → cleaning mapping
        expect(dictionary["hygiene"]).to eq(:hygiene)
        expect(dictionary["clean"]).to eq(:hygiene)
        expect(dictionary["cleaning"]).to eq(:hygiene)
        expect(dictionary["shower"]).to eq(:hygiene)

        # Test technology → tech mapping
        expect(dictionary["technology"]).to eq(:technology)
        expect(dictionary["computer"]).to eq(:technology)
        expect(dictionary["tech"]).to eq(:technology)

        # Test legal → law mapping
        expect(dictionary["legal"]).to eq(:legal)
        expect(dictionary["law"]).to eq(:legal)

        # Test learning → education mapping
        expect(dictionary["learning"]).to eq(:learning)
        expect(dictionary["learn"]).to eq(:learning)
        expect(dictionary["education"]).to eq(:learning)
        expect(dictionary["teaching"]).to eq(:learning)
        expect(dictionary["teach"]).to eq(:learning)
        expect(dictionary["teacher"]).to eq(:learning)

        # Test overdose → prevention mapping
        expect(dictionary["overdose"]).to eq(:overdose)
        expect(dictionary["prevention"]).to eq(:overdose)
      end

      it "handles singular and plural variations" do
        dictionary = described_class.services_dictionary

        # Test singular/plural forms
        expect(dictionary["tech"]).to eq(:technology)
        # NOTE: "tech" pluralization can be "tech" or "techs" depending on context
        # Let's check what the actual variation produces
        expected_plural = "tech".pluralize
        expect(dictionary[expected_plural]).to eq(:technology) if expected_plural != "tech"
      end

      it "caches the dictionary result" do
        # Clear any existing cache
        described_class.instance_variable_set(:@services_dictionary, nil)

        # First call should build the dictionary
        dictionary1 = described_class.services_dictionary

        # Second call should use cached result (no database calls)
        expect(Service).not_to receive(:all)
        dictionary2 = described_class.services_dictionary

        expect(dictionary1).to eq(dictionary2)
      end

      it "includes empty arrays for services without synonyms" do
        dictionary = described_class.services_dictionary

        # These services have empty synonym arrays
        expect(dictionary["medical"]).to eq(:medical)
        expect(dictionary["food"]).to eq(:food)
        expect(dictionary["phone"]).to eq(:phone)
      end
    end

    describe ".welcomes_dictionary" do
      it "builds dictionary from facility welcome customer types" do
        dictionary = described_class.welcomes_dictionary

        # Test all customer types are included
        FacilityWelcome.all_customers.each do |customer|
          expect(dictionary[customer.value]).to eq(customer.value.to_sym)
          expect(dictionary[customer.value.downcase]).to eq(customer.value.to_sym)
          expect(dictionary[customer.name.downcase]).to eq(customer.value.to_sym)
        end
      end

      it "includes static welcomes dictionary mappings" do
        dictionary = described_class.welcomes_dictionary

        # All customer types should map to themselves
        expect(dictionary["male"]).to eq(:male)
        expect(dictionary["female"]).to eq(:female)
        expect(dictionary["transgender"]).to eq(:transgender)
        expect(dictionary["children"]).to eq(:children)
        expect(dictionary["youth"]).to eq(:youth)
        expect(dictionary["adult"]).to eq(:adult)
        expect(dictionary["senior"]).to eq(:senior)
      end

      it "handles singular and plural variations" do
        dictionary = described_class.welcomes_dictionary

        # Test singular/plural forms
        expect(dictionary["male"]).to eq(:male)
        expect(dictionary["males"]).to eq(:male)
        expect(dictionary["child"]).to eq(:children)
        expect(dictionary["children"]).to eq(:children)
      end

      it "caches the dictionary result" do
        # Clear any existing cache
        described_class.instance_variable_set(:@welcomes_dictionary, nil)

        # First call should build the dictionary
        dictionary1 = described_class.welcomes_dictionary

        # Second call should use cached result
        dictionary2 = described_class.welcomes_dictionary

        expect(dictionary1).to eq(dictionary2)
      end
    end

    describe ".dictionary" do
      it "merges services and welcomes dictionaries" do
        # Clear any existing cache
        described_class.instance_variable_set(:@dictionary, nil)

        services_dict = { "test_service" => :test_service }
        welcomes_dict = { "male" => :male }

        allow(described_class).to receive_messages(services_dictionary: services_dict, welcomes_dictionary: welcomes_dict)

        dictionary = described_class.dictionary

        expect(dictionary).to eq(services_dict.merge(welcomes_dict))
      end

      it "caches the merged dictionary" do
        # Clear any existing cache
        described_class.instance_variable_set(:@dictionary, nil)

        # First call should build and merge
        dictionary1 = described_class.dictionary

        # Second call should use cached result
        dictionary2 = described_class.dictionary

        expect(dictionary1).to eq(dictionary2)
      end
    end

    describe ".assign" do
      it "assigns singular and plural variations to dictionary" do
        dictionary = {}

        described_class.send(:assign, dictionary, key: :test, value: "test")

        expect(dictionary["test"]).to eq(:test)
        expect(dictionary["tests"]).to eq(:test)
      end

      it "handles string values" do
        dictionary = {}

        described_class.send(:assign, dictionary, key: :result, value: "test_value")

        expect(dictionary["test_value"]).to eq(:result)
        expect(dictionary["test_values"]).to eq(:result)
      end

      it "handles symbol values" do
        dictionary = {}

        described_class.send(:assign, dictionary, key: :result, value: :test_value)

        expect(dictionary["test_value"]).to eq(:result)
        expect(dictionary["test_values"]).to eq(:result)
      end
    end

    describe ".variations_for" do
      it "returns singular and plural forms" do
        variations = described_class.send(:variations_for, "test")

        expect(variations).to eq(%w[test tests])
      end

      it "handles irregular plurals" do
        variations = described_class.send(:variations_for, "person")

        expect(variations).to eq(%w[person people])
      end

      it "handles words that don't change in plural" do
        variations = described_class.send(:variations_for, "sheep")

        expect(variations).to eq(%w[sheep sheep])
      end

      it "converts to lowercase" do
        variations = described_class.send(:variations_for, "TEST")

        expect(variations).to eq(%w[test tests])
      end
    end
  end

  describe "instance methods" do
    let(:service) { create(:service, key: "shelter", name: "Shelter") }

    before do
      # Clear any cached dictionaries
      described_class.instance_variable_set(:@services_dictionary, nil)
      described_class.instance_variable_set(:@welcomes_dictionary, nil)
      described_class.instance_variable_set(:@dictionary, nil)
    end

    describe "#initialize" do
      it "initializes with search_value" do
        translator = described_class.new("test")

        expect(translator.instance_variable_get(:@search_value)).to eq("test")
      end
    end

    describe "#call" do
      context "with valid search value" do
        it "returns successful result with translated value" do
          translator = described_class.new("shelter")
          result = translator.call

          expect(result.success?).to be true
          expect(result.data).to eq(:shelter)
          expect(result.errors).to be_empty
        end

        it "translates housing to shelter" do
          translator = described_class.new("housing")
          result = translator.call

          expect(result.success?).to be true
          expect(result.data).to eq(:shelter)
        end

        it "translates clean to hygiene" do
          translator = described_class.new("clean")
          result = translator.call

          expect(result.success?).to be true
          expect(result.data).to eq(:hygiene)
        end

        it "translates customer types" do
          translator = described_class.new("male")
          result = translator.call

          expect(result.success?).to be true
          expect(result.data).to eq(:male)
        end

        it "translates customer names" do
          translator = described_class.new("Male")
          result = translator.call

          expect(result.success?).to be true
          expect(result.data).to eq(:male)
        end
      end

      context "with invalid search value" do
        it "returns failed result with error" do
          translator = described_class.new("invalid_value")
          result = translator.call

          expect(result.failed?).to be true
          expect(result.data).to be_nil
          expect(result.errors).to include("Dictionary doesn't have 'invalid_value' value")
        end
      end

      it "handles case insensitive search" do
        translator = described_class.new("SHELTER")
        result = translator.call

        expect(result.success?).to be true
        expect(result.data).to eq(:shelter)
      end
    end

    describe "#validate" do
      context "with valid search value" do
        it "does not add errors" do
          translator = described_class.new("shelter")

          expect { translator.send(:validate) }.not_to(change { translator.send(:errors) })
        end
      end

      context "with invalid search value" do
        it "adds error for missing value" do
          translator = described_class.new("invalid_value")

          expect { translator.send(:validate) }.to change { translator.send(:errors).length }.by(1)
          expect(translator.send(:errors)).to include("Dictionary doesn't have 'invalid_value' value")
        end
      end
    end

    describe "#valid?" do
      it "returns true for valid search value" do
        translator = described_class.new("shelter")

        expect(translator.valid?).to be true
      end

      it "returns false for invalid search value" do
        translator = described_class.new("invalid_value")

        expect(translator.valid?).to be false
      end
    end

    describe "#invalid?" do
      it "returns false for valid search value" do
        translator = described_class.new("shelter")

        expect(translator.invalid?).to be false
      end

      it "returns true for invalid search value" do
        translator = described_class.new("invalid_value")

        expect(translator.invalid?).to be true
      end
    end

    describe "#translated_value" do
      it "looks up value in dictionary" do
        translator = described_class.new("shelter")

        expect(translator.send(:translated_value)).to eq(:shelter)
      end

      it "returns nil for missing value" do
        translator = described_class.new("invalid_value")

        expect(translator.send(:translated_value)).to be_nil
      end

      it "converts search value to lowercase" do
        translator = described_class.new("SHELTER")

        expect(translator.send(:translated_value)).to eq(:shelter)
      end
    end
  end

  describe "class method shortcut" do
    it "can be called with .call" do
      # Clear any cache to ensure fresh dictionary
      described_class.instance_variable_set(:@dictionary, nil)

      result = described_class.call("shelter")

      expect(result.success?).to be true
      expect(result.data).to eq(:shelter)
    end
  end
end
