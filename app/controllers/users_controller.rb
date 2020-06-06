class Api::UsersController < Api::ApplicationController

	# GET api/users
	def index
		@users = current_user.manageable_users

		@response = { users: UsersSerializer.new(@users) }
		render json: @response, status: :ok
	end #/index

	# POST api/users/:id/toggle_verified
	def toggle_verified
		user = User.find(params[:id])
		if (current_user.id == params[:id])
			error_json = { errors: ['Users cannot toggle their own verified status']}
			render json: error_json, status: :forbidden
		elsif !current_user.can_manage?(user)
			head :forbidden
		else
			if user.toggle_verified!
				render json: UserSerializer.new(user), status: :ok
			else
				error_json = { errors: @user.errors }
				render json: error_json, status: :unprocessable_entity
			end
		end
	end #/toggle_verified
	
	# POST api/users
	def create

	end #/create
	
	# PUT api/users/:id
	def update

	end #/update

	private

	def user_params
		# :verified
		# :admin,
		params.permit(
			:name,
			:email,
			:password_digest,
			:created_at,
			:updated_at,
			:activation_email_sent,
			:phone_number
		)
	end #/user_params

end #/UsersController
