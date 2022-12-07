import xgboost as xgb
from sklearn.model_selection import GridSearchCV
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error

# Load the dataset
df = pd.read_csv('path/to/dataset.csv')

# Preprocess the data
df = pd.get_dummies(df, columns=['country'])

# Split the data into training and test sets
X = df.drop(['deaths'], axis=1)
y = df['deaths']

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Use GridSearchCV to find the best hyperparameters
params = {
    'max_depth': [3, 5, 7],
    'eta': [0.1, 0.3, 0.5],
    'objective': ['reg:linear'],
    'eval_metric': ['mae']
}

dtrain = xgb.DMatrix(X_train, label=y_train)
dtest = xgb.DMatrix(X_test, label=y_test)

gscv = GridSearchCV(xgb.XGBRegressor(), params, cv=3, n_jobs=-1)
gscv.fit(X_train, y_train)

print('Best hyperparameters:', gscv.best_params_)

# Train the model
param = gscv.best_params_
model = xgb.train(param, dtrain)

# Make predictions on the test set
predictions = model.predict(dtest)

# Evaluate the model's performance
mae = mean_absolute_error(y_test, predictions)
print('Mean Absolute Error:', mae)
