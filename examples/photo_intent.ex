defmodule Examples.PhotoIntent do
  use AppleIntents.Intent, intent: "OrganizePhotos", domain: :photos
  use AppleIntents.Jido, task: "organize_photos"
end