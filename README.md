# SovereignRatingDifferences
Data and scripts used while developing my economics thesis about sovereign rating differences between credit rating agencies.

Besides the macro variables, the panel has six variables calculated from the individual ratings given by each of the three credit rating agencies considered. Diff\_UP\_SM represents the positive (UP) rating difference between S&P (S) and Moody's (M), while Diff\_DW\_SM represents the negative rating difference between the same two agencies.

Example:
* Diff\_UP\_SM = 2 for a given pair (country, year), meaning S&P gives a rating 2-notches higher than Moody's to this specific country;
* Diff\_DW\_SM = 1 for a given pair (country, year), meaning S&P gives a rating 1-notch lower than Moody's to this specific country;

The six variables are:
* Diff\_UP\_SM, higher rating from S&P when compared with Moody's rating;
* Diff\_DW\_SM, lower rating from S&P when compared with Moody's rating;
* Diff\_UP\_MF, higher rating from Moody's when compared with Fitch rating;
* Diff\_DW\_MF, lower rating from Moody's when compared with Fitch rating;
* Diff\_UP\_SF, higher rating from S&P when compared with Fitch rating;
* Diff\_DW\_SF, lower rating from S&P when compared with Fitch rating.

From the 1735 rows of the CondensedPanelData:
* Diff\_UP\_SM <> NULL in 1048 rows (<> 0 in 311 rows)
* Diff\_DW\_SM <> NULL in 1120 rows (<> 0 in 383 rows)
* Diff\_UP\_MF <> NULL in 866 rows  (<> 0 in 285 rows)
* Diff\_DW\_MF <> NULL in 802 rows  (<> 0 in 221 rows)
* Diff\_UP\_SF <> NULL in 1109 rows (<> 0 in 236 rows)
* Diff\_DW\_SF <> NULL in 1135 rows (<> 0 in 262 rows)
