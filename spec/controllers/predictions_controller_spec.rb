require 'spec_helper'

describe PredictionsController do
  include Devise::TestHelpers
  
  before(:each) do
    controller.stub!(:set_timezone)
  end
  
  describe 'getting the homepage' do
    it 'should map GET / to home action' do
      {:get => "/"}.should route_to("predictions#home") 
    end
    
    it 'should map home action to /' do
      assert_recognizes({:action => "home", :controller => "predictions"}, { :method=> :get, :path=> "/" })
    end
    
    it 'should assign a new prediction' do
      Prediction.stub!(:new).and_return(:new_prediction)
      get :home
      assigns[:prediction].should == :new_prediction
    end
    it 'should assign some responses' do
      Response.stub!(:recent).and_return(mock('responses', :limit => :responses))
      get :home
      assigns[:responses].should == :responses
    end
    
    it 'should return http sucess status response' do
      get :home
      response.response_code.should == 200
    end
  end
  
  describe 'getting the "unjudged" page' do
    it 'should assign the unjudged predictions' do
      Prediction.should_receive(:unjudged).and_return(:unjudged)
      get :unjudged
      assigns[:predictions].should == :unjudged
    end
    it 'should respond with http success status' do
      get :unjudged
      response.response_code.should == 200
    end
    it 'should render index template' do
      get :unjudged
      response.should render_template('predictions/index')
    end
  end
  
  describe 'getting the "happenstance" page' do
    describe 'unjudged' do
      before(:each) do
        @mock_collection = mock('collection').as_null_object
        Prediction.stub!(:unjudged).and_return(@mock_collection)
      end
      it 'should assign to commented' do
        get :happenstance
        assigns[:unjudged].should == @mock_collection
      end
      it 'should limit the predictions by 3' do
        @mock_collection.should_receive(:limit).with(3).and_return(@mock_collection)
        get :happenstance
      end
    end 
    describe 'judged' do
      before(:each) do
        @mock_collection = mock('collection').as_null_object
        Prediction.stub!(:judged).and_return(@mock_collection)
      end
      it 'should assign to commented' do
        get :happenstance
        assigns[:judged].should == @mock_collection
      end
      it 'should limit the predictions by 3' do
        @mock_collection.should_receive(:limit).with(3).and_return(@mock_collection)
        get :happenstance
      end
    end 
    describe 'with a recent responses collection' do
      before(:each) do
        @mock_collection = mock('collection').as_null_object
        Response.stub!(:recent).and_return(@mock_collection)
      end
      it 'should assign to commented' do
        get :happenstance
        assigns[:responses].should == @mock_collection
      end
      it 'should limit the comments by 6' do
        @mock_collection.should_receive(:limit).with(6).and_return(@mock_collection)
        get :happenstance
      end
    end
    describe 'with a recent predictions collection' do
      before(:each) do
        @mock_collection = mock('collection').as_null_object
        Prediction.stub!(:recent).and_return(@mock_collection)
      end
      it 'should assign to commented' do
        get :happenstance
        assigns[:recent].should == @mock_collection
      end
      it 'should limit the predictions by 3' do
        @mock_collection.should_receive(:limit).with(3).and_return(@mock_collection)
        get :happenstance
      end
    end
  end
  
  describe 'Getting a list of all predictions' do
    before(:each) do
      @recent = mock('recent predictions', :limit => nil)
      Prediction.stub!(:recent).and_return(@recent)
    end
    
    it 'should map /predictions to "index" action' do
      {:get => "/predictions"}.should route_to("predictions#index") 
    end
    
    it 'should map "index" action to /predictions' do
      assert_recognizes({:action => "index", :controller => "predictions"}, { :method=> :get, :path=> "/predictions" })
    end
    
    describe 'index of predictions' do
      it 'should find all recent predictions' do
        Prediction.should_receive(:recent)
        get :index
      end

      it 'should assign recent predictions for the view' do
        @recent.stub!(:limit).and_return(:recent_predictions)
        get :index
        assigns[:predictions].should == :recent_predictions
      end
      
      it 'should limit the results to 100 predictions' do
        @recent.should_receive(:limit).with(100)
        get :index
      end
    end
    
    describe 'statistics' do
      it 'should provide a statistics accessor for the view' do
        controller.should respond_to(:statistics)
      end

      it 'should delegate statistics to the wagers collection' do
        wagers = mock('wagers')
        Response.stub!(:wagers).and_return(wagers)
        wagers.stub!(:statistics).and_return(:statistics)
        controller.statistics.should == :statistics
      end
    end
    
    it 'should respond with http success status' do
      get :index
      response.response_code.should == 200
    end
    
    it 'should render index template' do
      get :index
      response.should render_template('predictions/index')
    end

    describe 'recent predictions index' do
      it 'should render' do
        get :index
        response.response_code.should == 200
      end

      it 'should assign the title' do
        get :index
        assigns[:title].should_not be_nil
      end
      describe 'collection' do
        before do
          @collection = []
          Prediction.stub!(:recent).and_return(@collection)
        end
        it 'should assign the collection' do
          @collection.stub!(:prefetch_joins).and_return(@collection)
          get :index
          assigns[:predictions].should == @collection
        end
      end
      it 'should assign the filter' do
        get :index
        assigns[:filter].should == 'recent'
      end
    end
  end
  
  describe 'Getting a form for a new Prediction' do
    describe 'current user signed in' do
      before do
        @user = User.new
        controller.stub(:authenticate_user!)
        controller.stub(:current_user).and_return(@user)
      end
    
     it 'should map "new" action to predictions/new' do
        {:get => "/predictions/new"}.should route_to("predictions#new") 
      end
    
      it 'should map GET to /predictions/new to "new" action' do
         assert_recognizes({:action => "new", :controller => "predictions"}, {:method=> :get, :path=> "/predictions/new" })
      end
    
      it 'should map GET to / to "index" action' do
        {:get => "/"}.should route_to("predictions#home") 
      end
    
      it 'should respond with http success status' do
        get :new
      response.should be_success
      end
    
      it 'should render new template' do
        get :new
        response.should render_template('predictions/new')
      end
    
      it 'should instantiate a new Prediction object' do
        Prediction.should_receive(:new)
        get :new
      end
    
      it 'should assign new prediction object for the view' do
        Prediction.stub!(:new).and_return(:prediction)
        get :new
        assigns[:prediction].should == :prediction
      end
    end
    
    describe 'current user not signed in' do
      it 'should redirect to the login page' do
        get :new
        response.should redirect_to(new_user_session_path)
      end
    
      it 'should store the destination url in the session' do
        controller.should_receive(:store_location)
        get :new
      end
    end  
  end
  
  describe 'Creating a new prediction' do
    def post_prediction(params={})
      post :create, :prediction => params
    end
    
    before(:each) do
      Prediction.stub!(:create!)
      Prediction.stub!(:recent)
      
      @user = User.new
      controller.stub(:authenticate_user!)
      controller.stub(:current_user).and_return(@user)
    end
        
    it 'should map POST to /predictions to "create" action' do
      {:post => "/predictions"}.should route_to("predictions#create") 
    end
    
    it 'should use the current_user as the creator' do
      Prediction.should_receive(:create!).with(hash_including(:creator => @user))
      post_prediction
    end

    it 'should create a new prediction with the POSTed params' do
      Prediction.should_receive(:create!).with(hash_including(:a => :param))
      post_prediction(:a => :param)
    end
      
    describe 'redirect' do
      before do
        @prediction = Prediction.new
      end
      it "should redirect to the prediction view page" do
        Prediction.stub!(:create!).and_return(@prediction)
        post_prediction
        
        response.should redirect_to(prediction_path(@prediction))
      end
      it 'should go to the index predictions view if there was a duplicate submit' do
        Prediction.stub!(:create!).and_raise(Prediction::DuplicateRecord.new(@prediction))
        post_prediction
      
        response.should redirect_to(prediction_path(@prediction))
      end
    end
    
    it 'should set the Time.zone to users preference' do
      controller.should_receive(:set_timezone).at_least(:once) # before filters suck in spec-land
      post_prediction
    end
    
    describe 'when the params are invalid' do
      before(:each) do
        prediction = mock_model(Prediction, :errors => mock('errors', :full_messages => []))
        Prediction.stub!(:create!).and_raise(ActiveRecord::RecordInvalid.new(prediction))
      end
      
      it 'should respond with an http unprocesseable entity status' do
        post_prediction
        response.response_code.should == 422
      end
      
      it 'should render "new" form' do
        post_prediction
        response.should render_template('predictions/new')
      end
      
      it 'should assign the prediction' do
        post_prediction
        assigns[:prediction].should_not be_nil
      end
    end
    
  end
  
  describe 'viewing a prediction' do
    before do
      @prediction = create_valid_prediction
      Prediction.stub!(:find).and_return(@prediction)
      controller.stub!(:logged_in?).and_return(true)
      controller.stub!(:current_user).and_return(mock_model(User))
      
      #@user = User.new
      #controller.stub(:authenticate_user!)
      #controller.stub(:current_user).and_return(@user)
    end
    it 'should map GET /preditions/:id to show' do
       {:get => "/predictions/6"}.should route_to("predictions#show", :id => "6") 
    end
    it 'should map show action to /predictions/:id' do
      assert_recognizes({:action => "show", :controller => "predictions", :id => "6"}, { :method=> :get, :path=> "/predictions/6" })
    end
    
    it 'should assign the prediction to prediction' do
      get :show, :id => '1'
      assigns[:prediction].should == @prediction
    end
    
    # TODO: Make blackbox (will probably have to hit DB)
    it 'should get the deadline notifications for the prediction' do
      dn = @prediction.deadline_notifications
      @prediction.should_receive(:deadline_notifications).at_least(:once).and_return(dn)
      get :show, :id => '1'
    end
    
    # TODO: too long
    it 'should filter the deadline notifications by the current user' do
      u = User.new
      controller.stub!(:current_user).and_return(u)
      @prediction.deadline_notifications.should_receive(:find_by_user_id).with(u).and_return(:a_dn)
      get :show, :id => '1'
      
      assigns[:deadline_notification].should == :a_dn
    end
    
    it 'should find the prediction based on id' do
      Prediction.should_receive(:find).with('5').and_return(@prediction)
      get :show, :id => '5'
    end
    
    describe 'private predictions' do
      before(:each) do
        @prediction.stub!(:private?).and_return(true)
        @prediction.stub!(:creator).and_return(@user = User.new)
      end
      it 'should be forbidden when not owned by current user' do
        controller.stub!(:current_user).and_return(User.new)
        get :show, :id => '1'
        response.response_code.should == 403
      end
      it 'should be forbidden when not logged in' do
        controller.stub!(:current_user).and_return(nil)
        controller.stub!(:logged_in?).and_return(false)
        get :show, :id => '1'
        response.response_code.should == 403
      end
      it 'should be viewable when user is current user' do
        controller.stub!(:current_user).and_return(@user)
        get :show, :id => '1'
        response.should be_success
      end
    end
        
    describe 'response object for commenting or wagering' do
      before(:each) do
        Prediction.stub!(:find).and_return create_valid_prediction
      end
      it 'should instantiate a new Response object' do
        Response.should_receive(:new)
        get :show, :id => '6'
      end
      it 'should assign new wager object for the view' do
        Response.stub!(:new).and_return :response
        get :show, :id => '6'
        assigns[:prediction_response].should == :response
      end
      it 'should assign the current user to the response' do
        user = User.new
        controller.stub!(:current_user).and_return(user)
        Response.should_receive(:new).with(hash_including({:user => user}))
        get :show, :id => '6'
      end
    end
  end
  
  describe 'Updating the outcome of a prediction' do
    before(:each) do
      @prediction = mock_model(Prediction, :to_param => '1').as_null_object
      Prediction.stub!(:find).and_return(@prediction)
    end
    
    def post_outcome(params={})
      post :judge, {:id => '1', :outcome => ''}.merge(params)
    end
      
    describe 'current user is signed in' do
      before(:each) do
        @user = User.new
        controller.stub(:authenticate_user!)
        controller.stub(:current_user).and_return(@user)
      end
    
      it 'should map POST to /predictions/:id/judge to "judge" action' do
        {:post => "/predictions/6/judge"}.should route_to("predictions#judge", :id => "6")
      end
    
      it 'should map "judge" action to /predictions/1/judge' do
        assert_recognizes({:action => "judge", :controller => "predictions", :id => "1"}, { :method=> :post, :path=> "/predictions/1/judge" })
      end
    
      it 'should set the prediction to the passed outcome on POST to outcome' do
        @prediction.should_receive(:judge!).with('right', anything)
        post_outcome :outcome => 'right'
      end
    
      it 'should pass in the user to the judge method' do
        controller.stub!(:current_user).and_return(:mr_user)
        @prediction.should_receive(:judge!).with(anything, :mr_user)
        post_outcome
      end
    
      it 'should find and assign the prediction based on passed through ID' do
        Prediction.should_receive(:find).with('444').and_return(@prediction)
        post_outcome :id => '444'
        assigns[:prediction].should == @prediction
      end
    
      it 'should redirect to prediction page after POST to outcome' do
        @prediction.stub!(:to_param).and_return('33')
        post_outcome :id => '33'
        response.should redirect_to(prediction_path('33'))
      end
    
      it 'should set a flash variable judged to a css class to apply to the judgment view' do
        post_outcome
        flash[:judged].should_not be_nil
      end
    end
    
    describe 'current user is not signed in' do
      it 'should require the user to be logged in' do
        post_outcome
        response.should redirect_to(new_user_session_path)
      end
    end
    
    describe 'expiring the cached statistics fragments for users' do
      before(:each) do
        User.destroy_all
        @prediction = create_valid_prediction
        Prediction.stub!(:find).and_return(@prediction)
        @prediction.stub!(:to_param).and_return("zippy")
      end
      
      it 'should expire fragment for the creator of the prediction' do
        lambda { post_outcome }.should expire_fragment("views/statistics_partial-#{@prediction.creator.to_param}")
      end
      it 'should expire fragment for other users that have wagered on the prediction' do
        mock_wager = mock_model(Response, :user => mock_model(User, :id => 'mr-meetoo', :to_param => 'mr-meetoo'))
        @prediction.stub!(:wagers).and_return([mock_wager])
        lambda { post_outcome }.should expire_fragment("views/statistics_partial-#{mock_wager.user.to_param}")
      end
      it "should not expire fragment for other users that haven't wagered on the prediction" do
        @prediction.stub!(:wagers).and_return([])
        lambda { post_outcome }.should_not expire_fragment("views/statistics_partial-not-mee")
      end
      it "should expire to application-wide statistics partial" do
        lambda { post_outcome }.should expire_fragment("views/statistics_partial")
      end
    end
  end

  describe 'Withdrawing a prediction' do
    before(:each) do
      @prediction = mock_model(Prediction, :id => '12').as_null_object
      Prediction.stub!(:find).and_return(@prediction)
    end
    
    describe 'when the current user is not signed in' do
      it 'should require the user to be logged in' do
        controller.stub!(:signed_in?).and_return(false)
        post :withdraw, :id => '12'
        response.should redirect_to(new_user_session_path)
      end
    end
    
    describe 'when the current user is signed in' do
      before(:each) do
        @user = User.new
        controller.stub(:authenticate_user!)
        controller.stub(:current_user).and_return(@user)
      end
        
      describe 'when the current user is the creator of the prediction' do
      
        before(:each) do
         controller.stub!(:must_be_authorized_for_prediction)
        end
  
        it 'should map POST to /predictions/:id/withdraw to withdraw action' do
          {:post => "/predictions/6/withdraw"}.should route_to("predictions#withdraw", :id => "6")
        end
    
        it 'should map the "withdraw" action to /predictions/1/withdraw' do
          assert_recognizes({:action => "withdraw", :controller => "predictions", :id => "1"}, { :method=> :post, :path=> "/predictions/1/withdraw" })
        end
    
        it 'should redirect to prediction page after POST to withdraw' do
          post :withdraw, :id => '12'
          response.should redirect_to(prediction_path('12'))
        end
    
        it 'should call the withdraw! method on the prediction' do
          @prediction.should_receive(:withdraw!)
          post :withdraw, :id => '12'
        end
      end
      describe 'when the current user is not the creator of the prediction' do
        it 'should deny access' do
          @prediction.stub!(:creator).and_return(User.new)
          post :withdraw, :id => '12'
          response.response_code.should == 403
        end
      end
    end  
  end
  
  [:unjudged, :judged, :future].each do |action|
    describe action do 
      it 'should render' do
        get action
        response.response_code.should == 200
      end
      it 'should assign the title' do
        get action
        assigns[:title].should_not be_nil
      end
      it 'should assign the collection' do
        Prediction.stub!(action).and_return(:collection)
        get action
        assigns[:predictions].should == :collection
      end
      it 'should assign the filter' do
        get action
        assigns[:filter].should == action.to_s
      end
    end
  end
  
  describe 'viewing a prediction' do
    before do
      @prediction = create_valid_prediction
      Prediction.stub!(:find).and_return(@prediction)
      controller.stub!(:logged_in?).and_return(true)
      controller.stub!(:current_user).and_return(mock_model(User))
    end
    
    it 'should map GET /preditions/:id to show' do      
      {:get => "/predictions/6"}.should route_to("predictions#show", :id => "6")
    end
    
    it 'should map show action to /predictions/:id' do
      assert_recognizes({:action => "show", :controller => "predictions", :id => "6"}, { :method=> :get, :path=> "/predictions/6" })
    end
    
    it 'should assign the prediction to @prediction' do
      get :show, :id => '1'
      assigns[:prediction].should == @prediction
    end
    
    it 'should assign the prediction events to @events' do
      get :show, :id => '1'
      assigns[:events].should == @prediction.events
    end

    
    # TODO: Make blackbox (will probably have to hit DB)
    it 'should get the deadline notifications for the prediction' do
      dn = @prediction.deadline_notifications
      @prediction.should_receive(:deadline_notifications).at_least(:once).and_return(dn)
      get :show, :id => '1'
    end
    
    # TODO: too long
    it 'should filter the deadline notifications by the current user' do
      u = User.new
      controller.stub!(:current_user).and_return(u)
      @prediction.deadline_notifications.should_receive(:find_by_user_id).with(u).and_return(:a_dn)
      get :show, :id => '1'
      
      assigns[:deadline_notification].should == :a_dn
    end
    
    it 'should find the prediction based on id' do
      Prediction.should_receive(:find).with('5').and_return(@prediction)
      get :show, :id => '5'
    end
    
    describe 'private predictions' do
      before(:each) do
        @prediction.stub!(:private?).and_return(true)
        @prediction.stub!(:creator).and_return(@user = User.new)
      end
      it 'should be forbidden when not owned by current user' do
        controller.stub!(:current_user).and_return(User.new)
        get :show, :id => '1'
        response.response_code.should == 403
      end
      it 'should be forbidden when not logged in' do
        controller.stub!(:current_user).and_return(nil)
        controller.stub!(:logged_in?).and_return(false)
        get :show, :id => '1'
        response.response_code.should == 403
      end
      it 'should be viewable when user is current user' do
        controller.stub!(:current_user).and_return(@user)
        get :show, :id => '1'
        response.should be_success
      end
    end
        
    describe 'response object for commenting or wagering' do
      before(:each) do
        Prediction.stub!(:find).and_return create_valid_prediction
      end
      it 'should instantiate a new Response object' do
        Response.should_receive(:new)
        get :show, :id => '6'
      end
      it 'should assign new wager object for the view' do
        Response.stub!(:new).and_return :response
        get :show, :id => '6'
        assigns[:prediction_response].should == :response
      end
      it 'should assign the current user to the response' do
        user = User.new
        controller.stub!(:current_user).and_return(user)
        Response.should_receive(:new).with(hash_including({:user => user}))
        get :show, :id => '6'
      end
    end
  end

  describe 'getting the edit form for a prediction' do
    it 'should require a login' do
      get :edit, :id => '1'
      response.should redirect_to(new_user_session_path)
    end
    describe 'when logged in' do
      before(:each) do
        controller.stub!(:authenticate_user!)
        @p = create_valid_prediction
      end
      it 'should require the user to have created the prediction' do
        controller.stub!(:current_user).and_return(User.new)
        get :edit, :id => @p.id
        response.response_code.should == 403
      end
      it 'should assign the prediction' do
        controller.stub!(:current_user).and_return(@p.creator)
        get :edit, :id => @p.id
        assigns[:prediction].should == @p
      end
    end
  end
  
  describe 'updating a prediction' do
    it 'should require a login' do
      put :update, :id => '1'
      response.should redirect_to(new_user_session_path)
    end
    describe 'when logged in' do
      before(:each) do
        controller.stub!(:authenticate_user!)
        @p = create_valid_prediction
      end
      it 'should require the user to have created the prediction' do
        controller.stub!(:current_user).and_return(User.new)
        put :update, :id => @p.id
        response.response_code.should == 403
      end
      it 'should update the prediction' do
        Prediction.stub!(:find).and_return(@p)
        @p.should_receive(:update_attributes!).with(:prediction_params)
        controller.stub!(:must_be_authorized_for_prediction)
        put :update, :id => @p.id, :prediction => :prediction_params
      end
    end
  end
end
