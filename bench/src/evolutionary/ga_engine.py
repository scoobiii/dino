import random
class GeneticAlgorithm:
    def tournament_selection(self, candidates, fitness_scores):
        idx1, idx2 = random.sample(range(len(candidates)), 2)
        return candidates[idx1] if fitness_scores[idx1] > fitness_scores[idx2] else candidates[idx2]
