require 'rack/request'
require 'builder'

module RackSessionAccess
  class Middleware
    # Initialize RackSessionAccess middleware
    #
    # @param app a rack application
    # @param options 
    #
    # Options:
    # * :key - rack session key
    def initialize(app, options = {})
      @app = app
      @key = options[:key] || 'rack.session'
      @routing = [
        [ 'GET', RackSessionAccess.path,      :show   ],
        [ 'GET', RackSessionAccess.edit_path, :edit   ],
        [ 'PUT', RackSessionAccess.path,      :update ]
      ]
    end

    def call(env)
      return render(500) do |xml|
        xml.h2("#{@key} env is not initialized")
      end unless env[@key]

      request = ::Rack::Request.new(env)

      if action = dispatch_action(request)
        send(action, request)
      else
        @app.call(env)
      end
    end

    protected

    # List session data
    def show(request)
      # force load session because it can be lazy loaded
      request.env[@key].delete(:rack_session_access_force_load_session)

      # session hash object
      session_hash = request.env[@key].to_hash

      case File.extname(request.path)
      when ".raw"
        render do |xml|
          xml.h2 "Raw rack session data"
          xml.pre RackSessionAccess.encode(session_hash)
        end
      else
        render do |xml|
          xml.h2 "Rack session data"
          xml.ul do |ul|
            session_hash.each do |k,v|
              ul.li("#{k.inspect} : #{v.inspect}")
            end
          end
          xml.p do |p|
            p.a("Edit", :href => action_path(:edit))
          end
        end
      end
    end

    # Render form for submit new session data
    def edit(request)
      render do |xml|
        xml.h2 "Update rack session"
        xml.p "Put marshalized and encoded with base64 ruby hash into the form"
        xml.form({
          :action  => action_path(:update),
          :method  => 'post',
          :enctype => 'application/x-www-form-urlencoded'
        }) do |form|
          form.input(:type => 'hidden', :name =>'_method', :value => 'put')
          form.textarea(:cols => 40, :rows => 10, :name => 'data') {}
          form.p do |p|
            p.input(:type => 'submit', :value => "Update")
          end
        end
      end
    end

    # Update session data
    def update(request)
      begin
        data = request.params['data']
        hash = RackSessionAccess.decode(data)
        hash.each { |k, v| request.env[@key][k] = v }
      rescue => e
        return render(400) do |xml|
          xml.h2("Bad data #{data.inspect}: #{e.message} ")
        end
      end

      redirect_to action_path(:show)
    end

    private

    # Dispatch action from request
    def dispatch_action(request)
      method = request_method(request)
      path = request.path.sub(/\.\w+$/, '')
      route = @routing.detect { |r| r[0] == method && r[1] == path }
      route[2] if route
    end

    # Return HTTP method, detect emulated method with _method param
    def request_method(request)
      return request.request_method           if request.request_method != 'POST'
      return request.params['_method'].upcase if request.params['_method']
      request.request_method
    end

    # @return path for given action name
    def action_path(action)
      @routing.detect { |r| r[2] == action }[1]
    end

    # @return redirect response to specified url
    def redirect_to(url)
      render(302, {"Location" => url}) do |xml|
        xml.a "You are being redirected", :href => url
      end
    end

    # @return html response
    def render(code = 200, headers = {})
      headers["Content-Type"] ||= "text/html"

      builder = Builder::XmlMarkup.new(:indent => 2)

      builder.html do |xml|
        xml.body do |body|
          yield body
        end
      end

      [ code, headers, [builder.target!] ]
    end

  end
end
