require 'open-uri'

module WebpackHelper
  class BundleNotFound < StandardError; end

  MANIFEST_PATH = 'public/packs/manifest.json'.freeze

  def javascript_bundle_tag(entry, **options)
    path = asset_bundle_path("#{entry}.js")

    options[:src] = path
    options[:defer] = true

    # async と defer を両方指定した場合、ふつうは async が優先されるが、
    # defer しか対応してない古いブラウザの挙動を考えるのが面倒なので、両方指定は防いでおく
    options.delete(:defer) if options[:async]

    javascript_include_tag '', **options
  end

  def stylesheet_bundle_tag(entry, **options)
    path = asset_bundle_path("#{entry}.css")

    options[:href] = path

    stylesheet_link_tag '', **options
  end

  private

  def asset_bundle_path(entry, **options)
    raise BundleNotFound, "Could not find bundle with name #{entry}" unless manifest.key? entry

    asset_path(asset_host + manifest.fetch(entry), **options)
  end

  def asset_host
    Rails.application.config.asset_host || ''
  end

  # TODO: rspecを導入する時test環境用のmanifestを用意する
  def manifest
    return @manifest ||= JSON.parse(File.read(MANIFEST_PATH)) if Rails.env.production?

    host = Rails.application.config.dev_server_host
    webpack_server_uri = "http://#{host}/packs/manifest.json"
    dev_manifest = OpenURI.open_uri(webpack_server_uri).read
    return @manifest ||= JSON.parse(dev_manifest) if Rails.env.development?
  end
end
