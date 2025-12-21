package model

type Game struct {
	Slug            string   `json:"slug"`
	Title           string   `json:"title"`
	Provider        string   `json:"provider"`
	Type            string   `json:"type"`
	Tags            []string `json:"tags"`
	PopularityScore int      `json:"popularityScore"`
}

type GameVector struct {
	Slug   string    `json:"slug"`
	Vector []float32 `json:"vector"`
}
