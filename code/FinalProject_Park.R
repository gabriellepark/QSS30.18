library(tidyverse)
library(fixest)
library(rvest)
library(lubridate)
library(patchwork)
library(broom)
library(scales)

# Defining MENA -----------------------------------------------------------


MENA <- c('ARE', 'BHR', 'DJI', 'DZA', 'EGY', 'IRN', 'IRQ', 'ISR', 'JOR', 'KWT', 
          'LBN', 'LBY', 'MAR', 'MLT', 'OMN', 'QAT', 'SAU', 'SYR', 'TUN', 'YEM')
MENA_long <- c("Algeria", "Bahrain", "Djibouti", "Egypt", "Iran", "Iraq", "Israel", "Jordan", 
                "Kuwait", "Lebanon", "Libya", "Malta", "Morocco", "Oman", "Qatar", 
                "Saudi Arabia", "Syria", "Tunisia", "United Arab Emirates", "Yemen")



# COVID data --------------------------------------------------------------


owid_cases <- read_csv("~/Documents/GitHub/QSS30.18/data/weekly_cases.csv") %>% 
  pivot_longer(
    cols = 2:ncol(.), 
    names_to = "country", 
    values_to = "cases"
  ) %>% 
  filter(country %in% MENA_long)  %>% 
  filter(date >= "2020-02-01",
         date <= "2022-03-31") 

owid_deaths <- read_csv("~/Documents/GitHub/QSS30.18/data/weekly_deaths.csv") %>% 
  pivot_longer(
    cols = 2:ncol(.), 
    names_to = "country", 
    values_to = "deaths"
  ) %>% 
  filter(country %in% MENA_long)  %>% 
  filter(date >= "2020-02-01",
         date <= "2022-03-31") 



s <- ggplot(owid_cases) +
  geom_smooth(aes(x = date, y = cases)) +
  labs(
    title = "COVID-19 Cases in Middle East and North Africa (MENA) Region Countries, February 2020 to March 2022",
    subtitle = "Source: Our World in Data and the WHO Coronavirus Dashboard",
    y = "Case Count",
    x = "Date"
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme_minimal() +
  facet_wrap(vars(country))

ggsave("~/Documents/GitHub/QSS30.18/figures/covid_cases_MENA.png", plot = s, width = 10, height = 8, dpi = 300)



# ACLED data -------------------------------------------------------------------



acled <- read_csv("~/Documents/GitHub/QSS30.18/data/2020-01-01-2022-05-31-Algeria-Bahrain-Djibouti-Egypt-Iran-Iraq-Israel-Jordan-Kuwait-Lebanon-Libya-Malta-Morocco-Oman-Qatar-Saudi_Arabia-Syria-Tunisia-United_Arab_Emirates-Yemen.csv") 


acled <- acled %>% 
  group_by(country) %>% 
  filter(country %in% MENA_long) %>% 
  mutate(country = case_when(
    country == "UAE" ~ "United Arab Emirates",
    TRUE ~ country
  )) 


ggplot(acled) +
  geom_bar(aes(x = event_type))

ggplot(acled) +
  geom_bar(aes(x = country))


acled_cleaned <- acled %>% 
  filter(event_type == "Battles" |
         # event_type == "Riots" |
         event_type == "Explosions/Remote Violence" |
         event_type == "Violence against civilians") %>% 
  group_by(event_date, country) %>% 
  summarise(conflictcount = n()) %>%
  mutate(event_date = as.Date(event_date, format = "%d %B %Y")) %>% 
  filter(event_date >= "2020-02-01",
         event_date <= "2022-03-31")  %>%
  ungroup() 


t <- ggplot(acled_cleaned) +
  geom_point(aes(x = event_date, y = conflictcount), alpha = .75, color = "darkgrey") +
  geom_smooth(aes(x = event_date, y = conflictcount), color = "black") +
  labs(
    title = "Conflict in Middle East and North Africa (MENA) Region Countries, February 2020 to March 2022",
    subtitle = "Source: ACLED (Raleigh et al., 2010)",
    y = "Number of Conflicts",
    x = "Date"
  ) +
  scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
  theme_minimal() +
  facet_wrap(vars(country))

ggsave("~/Documents/GitHub/QSS30.18/figures/conflict_MENA.png", plot = t, width = 10, height = 8, dpi = 300)


# Joining Covid case and conflict data ------------------------------------------------------------


df1 <-  left_join(acled_cleaned, owid_cases, by = c("country", "event_date" = "date")) %>% 
  filter(!is.na(cases)) %>% 
  group_by(country) %>% 
  arrange(event_date) %>% 
  # mutate(prevconflict_count = lag(conflictcount, n = 1)) %>% 
  ungroup()

# df1 is conflict cleaned and weekly covid cases





# Joining Covid death and conflict/Covid case data ------------------------------------------------------------------



df2 <-  left_join(df1, owid_deaths, by = c("country", "event_date" = "date")) %>% 
  mutate(year = year(event_date))

# df2 is conflict cleaned, covid cases, and covid deaths



# Health expenditure data ------------------------------------------------------



whodata <- read_csv("~/Documents/GitHub/QSS30.18/data/whodata.csv") %>% 
  filter(Location %in% MENA_long) %>% 
  select(Location, Period, Value) %>% 
  filter(Period >= 2020) 




# Aggregating all data ------------------------------------------------------------



aggregate <- left_join(df2, whodata, by = c("country" = "Location", "year" = "Period")) 

aggregate_noNA <- aggregate %>% 
  filter(!is.na(Value))
# this removes NA values for health expenditure



# Data analysis --------------------------------------------------------------------

# Covid cases and conflict
summary(lm(cases~conflictcount, data = df1))


feols(cases ~ conflictcount| event_date + country, cluster = ~ country, data = df1)



plot <- ggplot(df1) + 
  geom_point(aes(x = conflictcount, y = cases, color = country), alpha = .75) + 
  theme_minimal() + 
  scale_y_continuous(labels = label_number_si()) + 
  labs(
    title = "Conflict events and Covid-19 case counts in a given day, Feb. 2020 to March 2022",
    subtitle = "MENA region, Data is from Our World in Data/WHO and ACLED (Raleigh et al., 2010)",
    y = "Covid-19 case count",
    x = "Total conflict events in a day",
    color = "MENA Countries"
  )

ggsave("~/Documents/GitHub/QSS30.18/figures/conflict_vs_cases_MENA.png", plot = plot, width = 10, height = 8, dpi = 300)

# Covid deaths and conflict
summary(lm(deaths~conflictcount, data = df2))

feols(deaths ~ conflictcount | event_date + country, cluster = ~ country, data = df2)


ggplot(df2) +
  geom_point(aes(x = conflictcount,
                 y = deaths,
                 color =  country))


#  case counts as a predictor of deaths, see if there is a heterogeneous relationship between if a place has a high or low level of conflict
aggregate_highlow <- aggregate %>% 
  group_by(country) %>% 
  mutate(conflict = sum(conflictcount),
         high = ifelse(sum(conflictcount) > 100, 1, 0))


summary(lm(deaths ~ cases, data = filter(aggregate_highlow, high == 1)))
summary(lm(deaths ~ cases, data = filter(aggregate_highlow, high == 0)))


highc <- tidy(lm(deaths ~ cases, data = filter(aggregate_highlow, high == 1)))
lowc <- tidy(lm(deaths ~ cases, data = filter(aggregate_highlow, high == 0)))


coefs.df <- data.frame(outcome=c("High Conflict","Low Conflict"), 
                       coefs = c(highc$estimate[2], lowc$estimate[2]),
                       ses = c(highc$std.error[2], lowc$std.error[2]))

plot2 <- ggplot(coefs.df, aes(outcome, coefs)) + 
  geom_hline(yintercept = 0, lwd = .6, colour = "red", linetype = "dotted") + 
  geom_point(size = 3) + 
  geom_errorbar(aes(ymin = coefs - 1.96 * ses, ymax = coefs + 1.96 * ses), 
                lwd = .6, width = 0, position = position_dodge(width = 1)) + 
  theme_minimal() + 
  labs(
    title = "Heterogeneity of high and low conflict countries",
    subtitle = "Predicting Covid-19 deaths with case counts in the MENA region",
    x = "Level of Conflict", 
    y = "Coefficient of Case Count"
  ) + 
  coord_flip()

# Save the plot
ggsave("~/Documents/GitHub/QSS30.18/figures/conflict_coefficients_MENA.png", plot = plot2, width = 10, height = 8, dpi = 300)




# with health expenditure data



feols(cases ~ conflictcount * Value| event_date + country, cluster = ~ country, data = aggregate_noNA)

feols(deaths ~ conflictcount * Value| event_date + country, cluster = ~ country, data = aggregate_noNA)




df.healthe <- aggregate_noNA %>%
  group_by(country) %>%
  summarise(sd = sd(Value, na.rm = TRUE),
            mean = mean(Value, na.rm=T))

df.healthe$country <- with(df.healthe, reorder(country, mean))

k <- ggplot(df.healthe, aes(x = country, y = mean, ymin = mean - sd, ymax = mean + sd)) +
  geom_errorbar(width = 0.2) +
  geom_point(size = 1.5) +
  theme_minimal() +
  labs(
    title = "Current health expenditure as a percent of GDP (in USD) per capita",
    subtitle = "Source: WHO, in the MENA region in 2020 and 2021",
    x = "Country", 
    y = "Health expenditure (in USD)"
  ) +
  theme(axis.text.x = element_text(angle = 0))

ggsave("~/Documents/GitHub/QSS30.18/figures/health_expenditure_MENA.png", plot = k, width = 10, height = 8, dpi = 300)



# unused graphs -----------------------------------------------------------


aggregate1 <- aggregate %>% 
  filter(country == "Israel" | country == "Syria" | country == "Tunisia" | country == "Lebanon"  |  country == "Morocco" 
         |  country == "Yemen")
# https://theeffectbook.net/ch-FixedEffects.html 

ggplot(aggregate1) +
  geom_point(aes(x = conflictcount,
                 y = deaths,
                 color = country))


ggplot(data = df1, aes(x = conflictcount, y = cases)) +
  geom_point() +
  # Add the regression line
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE) +
  # Add labels and title
  labs(x = "Conflict Count", y = "COVID Deaths", title = "Linear Regression Model") +
  # Add theme settings (optional)
  theme_minimal()
