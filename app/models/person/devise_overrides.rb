# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Person::DeviseOverrides

  def send_reset_password_instructions # from lib/devise/models/recoverable.rb
    persisted? && super
  end

  def clear_reset_password_token!
    clear_reset_password_token
    save(validate: false)
  end

  def generate_reset_password_token!
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)

    self.reset_password_token   = enc
    self.reset_password_sent_at = Time.now.utc
    self.save(validate: false)

    raw
  end

  # Owner: Devise::Models::DatabaseAuthenticatable
  # We override this to allow users updating passwords when no password has been set
  def update_with_password(params, *options)
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if encrypted_password.nil? || valid_password?(current_password)
               update_attributes(params, *options)
             else
               assign_attributes(params, *options)
               self.valid?
               errors.add(:current_password, current_password.blank? ? :blank : :invalid)
               false
             end

    clean_up_passwords
    result
  end

  private

  def email_required?
    false
  end

  # Checks whether a password is needed or not. For validations only.
  # Passwords are required if the password or confirmation are being set somewhere.
  def password_required?
    !password.nil? || !password_confirmation.nil?
  end
end